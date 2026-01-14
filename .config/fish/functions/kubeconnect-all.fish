function kubeconnect-all
    if test (count $argv) -lt 1
        echo "Usage: kubeconnect-all <env>"
        echo "Example: kubeconnect-all devjakob"
        return 1
    end

    set env $argv[1]

    echo "============================"
    echo "        🌎 GCP (GKE)"
    echo "============================"

    # --- GCP ---
    set project (gcloud projects list --filter="name~'^ne-$env-'" --format="value(projectId)" | head -n1)

    if test -z "$project"
        echo "❌ No GCP project found for '$env'"
    else
        echo "🔍 Fetching GKE clusters in project: $project"
        set gke_clusters (gcloud container clusters list --project $project --format="value(name,location)")

        if test -z "$gke_clusters"
            echo "⚠️  No GKE clusters found."
        else
            for pair in $gke_clusters
                set cluster (echo $pair | awk '{print $1}')
                set zone (echo $pair | awk '{print $2}')
                echo "➡️  Connecting to GKE cluster $cluster (zone: $zone)"
                gcloud container clusters get-credentials $cluster --zone $zone --project $project
            end
        end
    end

    echo ""
    echo "============================"
    echo "        🟦 Azure (AKS)"
    echo "============================"

    echo "🔍 Fetching AKS clusters starting with '$env'..."

    # Filter Azure clusters containing "<env>"

    set aks_list (az aks list \
    --query "[?contains(name, '$env-')].[name, resourceGroup]" \
    --output tsv)

    if test -z "$aks_list"
        echo "⚠️  No AKS clusters found starting with '$env'"
    else
        # aks_list is TSV with 2 columns: <name> <resourceGroup>
        for line in $aks_list
            set name (echo $line | awk '{print $1}')
            set rg (echo $line | awk '{print $2}')

            # Extra safety: ensure actual prefix match, not just substring
            if string match -q "$env-*" $name
                echo "➡️  Connecting to AKS cluster $name (RG: $rg)"
                az aks get-credentials --resource-group $rg --name $name --overwrite-existing
            else
                echo "⏭️  Skipping $name (matched substring but does not start with '$env')"
            end
        end
    end

    echo ""
    echo "============================"
    echo "        🟧 AWS (EKS)"
    echo "============================"

    # --- AWS ---
    echo "🔍 Detecting AWS regions with EKS clusters..."
    set regions (aws ec2 describe-regions --query "Regions[].RegionName" --output text)

    set eks_found 0

    for region in $regions
        set eks_clusters (aws eks list-clusters --region $region --query "clusters[]" --output text)
        if test -n "$eks_clusters"
            echo "📍 Region $region has EKS clusters: $eks_clusters"
            for c in $eks_clusters
                echo "➡️  Connecting to EKS cluster $c (region: $region)"
                aws eks update-kubeconfig --name $c --region $region
                set eks_found 1
            end
        end
    end

    if test $eks_found -eq 0
        echo "⚠️ No EKS clusters detected in any region."
    end

    echo ""
    echo "===================================="
    echo "     ✅ All clusters connected!"
    echo "===================================="
end
