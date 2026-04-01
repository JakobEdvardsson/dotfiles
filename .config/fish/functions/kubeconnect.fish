function kubeconnect
    function __kubeconnect_usage
        echo "Usage: kubeconnect <target> [--orch <cluster-name>] [--provider gcp|azure|aws|all]"
        echo ""
        echo "Target forms:"
        echo "  staging            Search all staging projects/clusters"
        echo "  devjakob           Search all projects/clusters for that devenv"
        echo "  ne-staging-ut1m    Search only that exact project"
        echo "  production         Intended as the production target"
        echo "  neo4j-cloud        Search only the exact GCP project"
        echo ""
        echo "Options:"
        echo "  --orch <name>      Connect only to the exact cluster name"
        echo "  --provider <name>  Limit search to gcp, azure, aws, or all"
        echo ""
        echo "Examples:"
        echo "  kubeconnect staging"
        echo "  kubeconnect staging --orch staging-orch-0007"
        echo "  kubeconnect ne-staging-ut1m --orch staging-orch-0007"
        echo "  kubeconnect devjakob --orch devjakob-orch-0001"
        echo "  kubeconnect production --orch production-orch-0008"
        echo "  kubeconnect neo4j-cloud --orch production-orch-0008"
    end

    set -l env
    set -l orch
    set -l provider all
    set -l i 1

    while test $i -le (count $argv)
        set -l arg $argv[$i]

        switch $arg
            case --orch
                set i (math $i + 1)
                if test $i -gt (count $argv)
                    __kubeconnect_usage
                    return 1
                end
                set orch $argv[$i]
            case --provider
                set i (math $i + 1)
                if test $i -gt (count $argv)
                    __kubeconnect_usage
                    return 1
                end
                set provider $argv[$i]
            case --help -h
                __kubeconnect_usage
                return 0
            case '*'
                if test -z "$env"
                    set env $arg
                else
                    __kubeconnect_usage
                    return 1
                end
        end

        set i (math $i + 1)
    end

    if test -z "$env"
        __kubeconnect_usage
        return 1
    end

    if not contains -- $provider gcp azure aws all
        echo "Invalid provider '$provider'. Use one of: gcp, azure, aws, all."
        echo ""
        __kubeconnect_usage
        return 1
    end

    set -l connected 0

    if test "$provider" = all -o "$provider" = gcp
        echo "============================"
        echo "        GCP (GKE)"
        echo "============================"

        set -l projects (gcloud projects list --filter="projectId~'^(ne|ni)-$env-'" --format="value(projectId)")
        set -l projects_status $status

        if test $projects_status -ne 0
            echo "Failed to list GCP projects for '$env'."
            if test -n "$orch"
                return 1
            end
        else if test -z "$projects"
            echo "No GCP projects found for '$env'."
        else
            for project in $projects
                if test -n "$orch"
                    echo "Checking GKE clusters in $project for $orch"
                else
                    echo "Checking GKE clusters in $project"
                end

                set -l gke_clusters (gcloud container clusters list --project $project --format="value(name,location)" 2>/dev/null)
                set -l gke_status $status

                if test $gke_status -ne 0
                    echo "Skipping $project: unable to list clusters."
                    continue
                end

                if test -z "$gke_clusters"
                    continue
                end

                for pair in $gke_clusters
                    set -l fields (string split \t -- $pair)
                    set -l cluster $fields[1]
                    set -l location $fields[2]

                    if test -z "$cluster" -o -z "$location"
                        echo "Skipping malformed GKE cluster row in $project: $pair"
                        continue
                    end

                    if test -n "$orch"
                        if test "$cluster" != "$orch"
                            continue
                        end
                    end

                    echo "Connecting to GKE cluster $cluster in $project ($location)"
                    gcloud container clusters get-credentials $cluster --project $project --location $location
                    if test $status -eq 0
                        set connected 1
                        if test -n "$orch"
                            return 0
                        end
                    end
                end
            end
        end

        echo ""
    end

    if test "$provider" = all -o "$provider" = azure
        echo "============================"
        echo "        Azure (AKS)"
        echo "============================"

        if test -n "$orch"
            echo "Checking AKS clusters for $orch"
            set -l aks_rows (az aks list --query "[?name=='$orch'].[name,resourceGroup]" --output tsv 2>/dev/null)
        else
            echo "Checking AKS clusters for '$env'"
            set -l aks_rows (az aks list --query "[?contains(name, '$env-')].[name,resourceGroup]" --output tsv 2>/dev/null)
        end
        set -l aks_status $status

        if test $aks_status -ne 0
            echo "Failed to list AKS clusters."
            if test -n "$orch"
                return 1
            end
        else if test -z "$aks_rows"
            echo "No AKS clusters found."
        else
            for row in $aks_rows
                set -l fields (string split \t -- $row)
                set -l name $fields[1]
                set -l rg $fields[2]

                if test -z "$name" -o -z "$rg"
                    continue
                end

                if test -z "$orch"
                    if not string match -q "$env-*" -- $name
                        continue
                    end
                end

                echo "Connecting to AKS cluster $name ($rg)"
                az aks get-credentials --resource-group $rg --name $name --overwrite-existing
                if test $status -eq 0
                    set connected 1
                    if test -n "$orch"
                        return 0
                    end
                end
            end
        end

        echo ""
    end

    if test "$provider" = all -o "$provider" = aws
        echo "============================"
        echo "        AWS (EKS)"
        echo "============================"

        set -l regions (aws ec2 describe-regions --query "Regions[].RegionName" --output text 2>/dev/null)
        set -l regions_status $status

        if test $regions_status -ne 0
            echo "Failed to list AWS regions."
            if test -n "$orch"
                return 1
            end
        else
            for region in $regions
                if test -n "$orch"
                    set -l eks_clusters (aws eks list-clusters --region $region --query "clusters[?@=='$orch']" --output text 2>/dev/null)
                else
                    set -l eks_clusters (aws eks list-clusters --region $region --query "clusters[]" --output text 2>/dev/null)
                end
                set -l eks_status $status

                if test $eks_status -ne 0 -o -z "$eks_clusters"
                    continue
                end

                for cluster in $eks_clusters
                    if test -z "$orch"
                        if not string match -q "$env-*" -- $cluster
                            continue
                        end
                    end

                    echo "Connecting to EKS cluster $cluster ($region)"
                    aws eks update-kubeconfig --name $cluster --region $region
                    if test $status -eq 0
                        set connected 1
                        if test -n "$orch"
                            return 0
                        end
                    end
                end
            end
        end

        echo ""
    end

    if test $connected -eq 1
        echo "Done."
        return 0
    end

    if test -n "$orch"
        echo "No cluster named '$orch' found for environment '$env'."
    else
        echo "No clusters found for environment '$env'."
    end

    return 1
end
