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

    # bass serializes env values with json.dumps, so embedded newlines arrive as
    # the literal two characters "\n", which fish does not decode inside double
    # quotes. That silently corrupts multi-line secrets (raw PEM private keys),
    # making component-machinery fail with "failed to decode private key PEM".
    # Restore real newlines for raw PEM vars only; JSON service-account keys rely
    # on literal "\n" inside the JSON, so they must not be touched.
    for var in NEO4J_DEV_IO_TLS_KEY NEO4J_IO_TLS_KEY
        if set -q $var
            set -gx $var (string replace -a '\n' \n -- "$$var" | string collect)
        end
    end
end
