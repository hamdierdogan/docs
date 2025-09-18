#!/bin/bash

# PostgreSQL connection string
DB_URL='postgresql://neondb_owner:npg_lUi6Yw0OPjsq@ep-small-silence-agjg0s9s-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'

# Get all projects with their images from database
psql "$DB_URL" -t -A -F '|' << 'EOF' > /tmp/projects_data.txt
SELECT slug, mintlify->'images'
FROM projects
WHERE mintlify->'images' IS NOT NULL
ORDER BY slug;
EOF

echo "Projects data exported to /tmp/projects_data.txt"

# Read the file and process each project
while IFS='|' read -r slug images; do
    # Skip if empty
    if [[ -z "$slug" ]]; then
        continue
    fi

    # MDX file path
    mdx_file="/home/hamdierdogan/docs/projeler/${slug}.mdx"

    # Check if MDX file exists
    if [[ ! -f "$mdx_file" ]]; then
        echo "MDX file not found for: $slug"
        continue
    fi

    echo "Processing: $slug"

    # Parse JSON images array and create gallery component
    gallery_component=$(cat << GALLERY_EOF

## Proje Görselleri

<CardGroup cols={2}>
GALLERY_EOF
)

    # Convert JSON array to image cards
    image_count=$(echo "$images" | jq 'length')

    for ((i=0; i<$image_count; i++)); do
        image_url=$(echo "$images" | jq -r ".[$i]")
        image_num=$((i + 1))

        gallery_component+=$(cat << IMG_EOF

  <Card>
    <img
      src="$image_url"
      alt="${slug} - Görsel $image_num"
      className="w-full h-auto rounded-lg shadow-lg"
      loading="lazy"
    />
  </Card>
IMG_EOF
)
    done

    gallery_component+="
</CardGroup>"

    # Add gallery to MDX file (before the closing tip/note if exists, otherwise at the end)
    # First check if gallery section already exists
    if grep -q "## Proje Görselleri" "$mdx_file"; then
        echo "Gallery section already exists in $mdx_file, skipping..."
    else
        # Add gallery section before the last Tip or Note block if exists
        if grep -q "<Tip>" "$mdx_file" || grep -q "<Note>" "$mdx_file"; then
            # Find the line number of the last Tip or Note
            last_tip_line=$(grep -n "<Tip>\|<Note>" "$mdx_file" | tail -1 | cut -d: -f1)

            # Insert gallery before that line
            head -n $((last_tip_line - 1)) "$mdx_file" > /tmp/temp_mdx.txt
            echo "$gallery_component" >> /tmp/temp_mdx.txt
            echo "" >> /tmp/temp_mdx.txt
            tail -n +$last_tip_line "$mdx_file" >> /tmp/temp_mdx.txt
            mv /tmp/temp_mdx.txt "$mdx_file"
        else
            # Just append at the end
            echo "$gallery_component" >> "$mdx_file"
        fi

        echo "Added gallery to $mdx_file with $image_count images"
    fi
done < /tmp/projects_data.txt

echo "MDX files updated with image galleries!"