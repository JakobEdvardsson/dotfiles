function kubeconnect --description "Connect to a cluster by exact name"
    function __kubeconnect_usage
        echo "Usage: kubeconnect [-c] <cluster-name> [cluster-name ...]"
        echo ""
        echo "Examples:"
        echo "  kubeconnect production-orch-1276"
        echo "  kubeconnect -c staging-infra staging-orch-0001"
        echo "  kubeconnect staging-infra"
        echo "  kubeconnect staging-orch-0007"
        echo "  kubeconnect devjakob-orch-0001"
    end

    function __kubeconnect_env_dir
        switch $argv[1]
            case production
                echo prod
            case '*'
                echo $argv[1]
        end
    end

    function __kubeconnect_env_metadata_dir
        set -l env_name $argv[1]
        set -l env_dir (__kubeconnect_env_dir $env_name)
        set -l clusters_dir /home/jakobe/code/neo4j-cloud/services/environment/clusters

        if test -d "$clusters_dir/$env_dir"
            echo $env_dir
            return 0
        end

        if string match -q 'dev*' -- $env_name
            echo dev
            return 0
        end

        echo $env_dir
    end

    function __kubeconnect_aws_profile_from_account
        set -l aws_accounts_file /home/jakobe/code/neo4j-cloud/services/environment/aws-aura-accounts.json

        if test ! -f "$aws_accounts_file"
            return 1
        end

        jq -r --arg account_id "$argv[1]" '.[] | select(.account_id == $account_id) | .name' "$aws_accounts_file" | head -n1
    end

    function __kubeconnect_ensure_aws_profile
        set -l profile $argv[1]
        set -l account_id $argv[2]
        set -l region $argv[3]

        mkdir -p ~/.aws
        if test ! -f ~/.aws/config
            touch ~/.aws/config
        end

        if not grep -q "^\[profile $profile\]" ~/.aws/config
            aws configure set sso_start_url https://d-9067b11262.awsapps.com/start --profile $profile
            or return 1
            aws configure set sso_region us-east-1 --profile $profile
            or return 1
            aws configure set sso_account_id $account_id --profile $profile
            or return 1
            aws configure set sso_role_name AuraDeveloper --profile $profile
            or return 1
            aws configure set region $region --profile $profile
            or return 1
        end
    end

    function __kubeconnect_gcp_project_for_env
        set -l env_name $argv[1]

        switch $env_name
            case production
                echo neo4j-cloud
                return 0
            case staging
                echo ne-staging-ut1m
                return 0
            case prestaging
                echo ne-prestaging-w80j
                return 0
        end

        gcloud projects list --filter="projectId~'^ne-$env_name-'" --format="value(projectId)" | head -n1
    end

    function __kubeconnect_gke_location
        set -l project $argv[1]
        set -l cluster $argv[2]

        gcloud container clusters list --project $project --format="value(name,location)" 2>/dev/null | awk -F '\t' -v target="$cluster" '$1 == target { print $2; exit }'
    end

    function __kubeconnect_jq_key_or_first
        set -l file $argv[1]
        set -l key $argv[2]

        jq -r --arg key "$key" 'if has($key) then $key else (keys[0] // empty) end' "$file"
    end

    function __kubeconnect_one
        set -l cluster $argv[1]

        set -l env_name (string match -r '^[^-]+' -- $cluster)
        if test -z "$env_name"
            echo "Expected an exact cluster name like 'production-orch-1276' or 'staging-infra'."
            return 1
        end

        set -l repo_root /home/jakobe/code/neo4j-cloud
        set -l env_dir (__kubeconnect_env_metadata_dir $env_name)
        set -l clusters_file "$repo_root/services/environment/clusters/$env_dir/orchestras.json.m4"
        set -l brain_file "$repo_root/services/environment/clusters/$env_dir/brain.json.m4"
        set -l isolation_units_file "$repo_root/services/environment/isolation-units/$env_dir.json.m4"

        set -l kind
        set -l region
        set -l isolation_id
        set -l is_brain 0

        if string match -q '*-infra' -- $cluster
            if test ! -f "$brain_file"
                echo "Brain metadata file not found: $brain_file"
                return 1
            end

            set -l brain_key (__kubeconnect_jq_key_or_first $brain_file $cluster)
            set kind (jq -r --arg cluster "$brain_key" '.[$cluster].kind // empty' "$brain_file")
            set region (jq -r --arg cluster "$brain_key" '.[$cluster].spec.region // empty' "$brain_file")
            set is_brain 1

            if test -z "$kind" -o -z "$region"
                echo "Cluster '$cluster' was not found in $brain_file"
                return 1
            end
        else
            if test ! -f "$clusters_file"
                echo "Cluster metadata file not found: $clusters_file"
                return 1
            end

            if test ! -f "$isolation_units_file"
                echo "Isolation unit metadata file not found: $isolation_units_file"
                return 1
            end

            set -l cluster_key (__kubeconnect_jq_key_or_first $clusters_file $cluster)
            set kind (jq -r --arg cluster "$cluster_key" '.[$cluster].kind // empty' "$clusters_file")
            set region (jq -r --arg cluster "$cluster_key" '.[$cluster].spec.region // empty' "$clusters_file")
            set isolation_id (jq -r --arg cluster "$cluster_key" '.[$cluster].isolation_id // empty' "$clusters_file")

            if test -z "$kind" -o -z "$region" -o -z "$isolation_id"
                echo "Cluster '$cluster' was not found in $clusters_file"
                return 1
            end
        end

        if test $is_brain -eq 1
            if test "$kind" != "gcp"
                echo "Unsupported brain cluster kind '$kind' for '$cluster'."
                return 1
            end

            set -l brain_project (__kubeconnect_gcp_project_for_env $env_name)
            if test -z "$brain_project"
                echo "Unable to infer GCP project for brain cluster '$cluster'."
                return 1
            end

            if string match -q '_*' -- $region
                set region (__kubeconnect_gke_location $brain_project $cluster)
                if test -z "$region"
                    echo "Unable to infer region for brain cluster '$cluster' in $brain_project."
                    return 1
                end
            end

            echo "Connecting to GKE cluster $cluster in $brain_project ($region)"
            gcloud container clusters get-credentials $cluster --project $brain_project --location $region
            return $status
        end

        set -l resources (jq -r --arg isolation_id "$isolation_id" '.[] | select(.isolation_id == $isolation_id) | [(.resources.gcp_project_id // ""), (.resources.aws_account_id // ""), (.resources.azure_subscription_id // "")] | @tsv' "$isolation_units_file")

        if test -z "$resources"
            echo "Isolation unit '$isolation_id' was not found in $isolation_units_file"
            return 1
        end

        set -l resource_fields (string split \t -- $resources)
        set -l gcp_project_id $resource_fields[1]
        set -l aws_account_id $resource_fields[2]
        set -l azure_subscription_id $resource_fields[3]

        if test "$kind" = "gcp"
            if string match -q '_*' -- $gcp_project_id
                set gcp_project_id (__kubeconnect_gcp_project_for_env $env_name)
                if test -z "$gcp_project_id"
                    echo "Unable to infer GCP project for cluster '$cluster'."
                    return 1
                end
            end

            if string match -q '_*' -- $region
                set region (__kubeconnect_gke_location $gcp_project_id $cluster)
                if test -z "$region"
                    echo "Unable to infer region for cluster '$cluster' in $gcp_project_id."
                    return 1
                end
            end
        end

        switch $kind
            case gcp
                echo "Connecting to GKE cluster $cluster in $gcp_project_id ($region)"
                gcloud container clusters get-credentials $cluster --project $gcp_project_id --location $region
                return $status

            case aws
                set -l inferred_profile (__kubeconnect_aws_profile_from_account $aws_account_id)

                if test -z "$inferred_profile"
                    echo "Unable to infer AWS profile for account $aws_account_id."
                    return 1
                end

                __kubeconnect_ensure_aws_profile $inferred_profile $aws_account_id $region
                if test $status -ne 0
                    echo "Failed to configure AWS profile $inferred_profile."
                    return 1
                end

                set -gx AWS_PROFILE $inferred_profile
                echo "Using AWS profile $AWS_PROFILE"

                aws sts get-caller-identity >/dev/null 2>/dev/null
                if test $status -ne 0
                    echo "Running AWS SSO login for $AWS_PROFILE"
                    aws sso login --profile $AWS_PROFILE
                    if test $status -ne 0
                        return 1
                    end
                end

                echo "Connecting to EKS cluster $cluster ($region)"
                aws eks update-kubeconfig --name $cluster --region $region
                return $status

            case azure
                if test -n "$azure_subscription_id"
                    az account set --subscription $azure_subscription_id
                    if test $status -ne 0
                        return 1
                    end
                end

                set -l aks_rows (az aks list --query "[?name=='$cluster'].[name,resourceGroup]" --output tsv 2>/dev/null)
                if test -z "$aks_rows"
                    echo "No AKS cluster named '$cluster' found."
                    return 1
                end

                set -l fields (string split \t -- $aks_rows[1])
                set -l name $fields[1]
                set -l rg $fields[2]

                if test -z "$name" -o -z "$rg"
                    echo "Failed to resolve resource group for AKS cluster '$cluster'."
                    return 1
                end

                echo "Connecting to AKS cluster $name ($rg)"
                az aks get-credentials --resource-group $rg --name $name --overwrite-existing
                return $status

            case '*'
                echo "Unsupported cluster kind '$kind' for '$cluster'."
                return 1
        end
    end

    set -l clean 0
    set -l clusters

    for arg in $argv
        switch $arg
            case -c --clean
                set clean 1
            case -h --help
                __kubeconnect_usage
                return 0
            case '*'
                set -a clusters $arg
        end
    end

    if test (count $clusters) -lt 1
        __kubeconnect_usage
        return 1
    end

    if test $clean -eq 1
        tp ~/.kube/config
    end

    for cluster in $clusters
        __kubeconnect_one $cluster
        if test $status -ne 0
            return 1
        end
    end
end
