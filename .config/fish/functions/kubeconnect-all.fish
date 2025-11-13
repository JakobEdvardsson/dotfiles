function kubeconnect-all
    if test (count $argv) -lt 1
        echo "Usage: kubeconnect-all <env>"
        echo "Example: kubeconnect-all devjakob"
        return 1
    end

    set env $argv[1]

    # Find project dynamically
    set project (gcloud projects list --filter="name~'^ne-$env'" --format="value(projectId)" | head -n1)

    if test -z "$project"
        echo "❌ No project found for environment '$env'"
        return 1
    end

    echo "🔍 Fetching clusters in project $project ..."
    set clusters (gcloud container clusters list --project $project --format="value(name,location)")

    if test -z "$clusters"
        echo "⚠️  No clusters found in project $project"
        return 1
    end

    echo "🔑 Authenticating to all clusters..."
    for pair in $clusters
        set cluster (echo $pair | awk '{print $1}')
        set zone (echo $pair | awk '{print $2}')
        echo "➡️  Connecting to cluster $cluster (zone: $zone)"
        gcloud container clusters get-credentials $cluster --zone $zone --project $project
    end

    echo "✅ All clusters added to kubeconfig."
end
