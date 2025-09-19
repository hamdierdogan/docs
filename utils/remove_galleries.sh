#!/bin/bash

# Remove all image galleries from MDX files
for file in projeler/*.mdx; do
    if grep -q "## Proje Görselleri" "$file"; then
        filename=$(basename "$file")
        echo "Removing gallery from: $filename"

        # Remove everything from "## Proje Görselleri" to the line before "---" at the end
        sed -i '/^## Proje Görselleri$/,/^---$/{/^---$/!d;}' "$file"
    fi
done

echo "All galleries removed!"