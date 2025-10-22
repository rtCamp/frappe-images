build:
    # Build all the docker images
    @echo "🐳 Rendering the Dockerfiles for the versions.json"
    @python3 -c "import json,subprocess;[subprocess.run(['./.venv/bin/dpn','dockerfile','--context',json.dumps(v)],check=True) for v in json.load(open('versions.json'))['versions']]"
    @echo "🐳 Building all python docker images in dockerfiles/"
    @set -x; for f in dockerfiles/python*.Dockerfile; do \
        tag="frappe:python-${f#dockerfiles/python}"; \
        tag="${tag%.Dockerfile}"; \
        echo "🐳 Building $tag from $f ..."; \
        docker build -t "$tag" -f "$f" . ; \
    done
