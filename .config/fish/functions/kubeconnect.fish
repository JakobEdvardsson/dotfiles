function kubeconnect
    # Require two arguments: <env> and <cluster>
    if test (count $argv) -lt 2
        echo "Usage: kubeconnect <env> <cluster>"
        echo "Example: kubeconnect devjakob orch-0001"
        return 1
    end

    set env $argv[1]
    set cluster $argv[2]

    # Find project dynamically based on env prefix
    set project (gcloud projects list --filter="name~'^ne-$env-'" --format="value(projectId)" | head -n1)

    if test -z "$project"
        echo "❌ No project found for environment '$env'"
        return 1
    end

    # Construct cluster name and fetch zone dynamically if possible
    set cluster_name "$env-$cluster"
    set zone (gcloud container clusters list --project $project --format="value(location)" --filter="name=$cluster_name" | head -n1)

    if test -z "$zone"
        echo "⚠️  Could not detect zone automatically, using default 'europe-west1'"
        set zone europe-west1
    end

    echo "➡️  Connecting to cluster $cluster_name in project $project (zone: $zone)"
    gcloud container clusters get-credentials $cluster_name --project=$project --zone=$zone
end
