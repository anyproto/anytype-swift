SOURCE_DIR="Sources/Protocol/Commands"
TEMPLATE="Templates/invocation-adoption.stencil"
OUTPUT_DIR="Sources/Generated/CommandsInvocation"

cd ../

if [ -d "$OUTPUT_DIR" ]; then
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

for file in "$SOURCE_DIR"/*.swift; do
    if [[ -f "$file" ]]; then
        filename=$(basename -- "$file")
        filename_noext="${filename%.*}"
        output_file="$OUTPUT_DIR/${filename_noext}+InvocationGenerated.swift"

        sourcery --quiet --sources "$file" --templates "$TEMPLATE" --output "$output_file"
    fi
done
