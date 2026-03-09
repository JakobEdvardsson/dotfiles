function prodconnect
    if test (count $argv) -lt 2
        echo "Usage: prodconnect <gcp|azure|aws> <cluster-name>"
        echo "Example: prodconnect gcp production-orch-0008"
        return 1
    end

    set provider $argv[1]
    set cluster_name $argv[2]

    switch $provider
        case gcp
            set project neo4j-cloud
            set location (gcloud container clusters list --project $project --format="value(location)" --filter="name=$cluster_name" | head -n1)

            if test -z "$location"
                echo "❌ No GKE cluster named '$cluster_name' found in project '$project'"
                return 1
            end

            echo "➡️  Connecting to GKE cluster $cluster_name in project $project (location: $location)"
            gcloud container clusters get-credentials $cluster_name --project=$project --location=$location
            return $status

        case azure aks
            set aks_match (az aks list --query "[?name=='$cluster_name'].[name,resourceGroup]" --output tsv)
            if test -z "$aks_match"
                echo "❌ No AKS cluster named '$cluster_name' found"
                return 1
            end

            set resource_group (echo $aks_match | awk '{print $2}')
            echo "➡️  Connecting to AKS cluster $cluster_name (resource group: $resource_group)"
            az aks get-credentials --resource-group $resource_group --name $cluster_name --overwrite-existing
            return $status

        case aws eks
            set regions (aws ec2 describe-regions --query "Regions[].RegionName" --output text)
            for region in $regions
                set found (aws eks list-clusters --region $region --query "clusters[?@=='$cluster_name']" --output text)
                if test "$found" = "$cluster_name"
                    echo "➡️  Connecting to EKS cluster $cluster_name (region: $region)"
                    aws eks update-kubeconfig --name $cluster_name --region $region
                    return $status
                end
            end

            echo "❌ No EKS cluster named '$cluster_name' found in any AWS region"
            return 1

        case '*'
            echo "❌ Unsupported provider '$provider'. Use: gcp, azure, or aws."
            return 1
    end
end
