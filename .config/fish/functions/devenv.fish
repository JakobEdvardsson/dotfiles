function devenv --description "Load the neo4j-cloud devenv bash environment into the current fish shell"
    set -l devenv_file ./devenv
    if not test -f "$devenv_file"
        echo "devenv: no 'devenv' file here; run this from the neo4j-cloud repo root" >&2
        return 1
    end
    bass source "$devenv_file"
    set -l bass_status $status
    if test $bass_status -ne 0
        return $bass_status
    end
end
