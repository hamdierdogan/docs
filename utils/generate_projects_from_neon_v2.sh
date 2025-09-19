#!/bin/bash

# Neon database connection
DB_URL='postgresql://neondb_owner:npg_lUi6Yw0OPjsq@ep-small-silence-agjg0s9s-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'

# Projects directory
PROJECTS_DIR="/home/hamdierdogan/docs/projeler"

# Clean up function for Turkish characters
clean_title() {
  echo "$1" | sed 's/Ş/S/g; s/ş/s/g; s/Ğ/G/g; s/ğ/g/g; s/Ü/U/g; s/ü/u/g; s/Ö/O/g; s/ö/o/g; s/Ç/C/g; s/ç/c/g; s/İ/I/g; s/ı/i/g'
}

# Remove existing project MDX files (except index files)
echo "Removing existing project MDX files..."
find "$PROJECTS_DIR" -name "*.mdx" ! -name "konut-projeleri.mdx" ! -name "ticari-projeler.mdx" -delete

# Generate MDX files from Neon database
echo "Generating MDX files from Neon database..."

psql "$DB_URL" -t -A -F'|' << 'EOF' | while IFS='|' read -r project_name slug images_json; do
SELECT
  project_name,
  slug,
  cloudinary_images::text
FROM projects
WHERE slug IS NOT NULL AND slug != ''
ORDER BY project_name;
EOF

  # Create proper filename from slug
  filename="$slug"
  mdx_file="$PROJECTS_DIR/${filename}.mdx"

  echo "Creating: $mdx_file"

  # Clean project name for title
  title="$project_name"
  clean_title=$(clean_title "$title")

  # Create MDX content
  cat > "$mdx_file" << MDXEOF
---
title: "$clean_title"
description: "$clean_title projesi"
---

# $clean_title

<Frame>
MDXEOF

  # Add first image as hero image
  first_image=$(echo "$images_json" | jq -r '.[0].secure_url // empty' 2>/dev/null)
  if [ -n "$first_image" ]; then
    echo "  <img src=\"$first_image\" alt=\"$clean_title\" />" >> "$mdx_file"
  fi

  cat >> "$mdx_file" << MDXEOF
</Frame>

## Proje Bilgileri

<CardGroup cols={2}>
  <Card title="Konum" icon="location-dot">
    **Bodrum**
  </Card>
  <Card title="Yıl" icon="calendar">
    **-**
  </Card>
  <Card title="Tip" icon="building">
    **-**
  </Card>
  <Card title="Durum" icon="check">
    **-**
  </Card>
</CardGroup>

## Galeri

<CardGroup cols={3}>
MDXEOF

  # Add all images to gallery
  echo "$images_json" | jq -r '.[] | .secure_url' 2>/dev/null | while read -r image_url; do
    if [ -n "$image_url" ]; then
      cat >> "$mdx_file" << MDXEOF
  <Card>
    <Frame>
      <img src="$image_url" alt="$clean_title" />
    </Frame>
  </Card>
MDXEOF
    fi
  done

  echo "</CardGroup>" >> "$mdx_file"
done

echo "MDX generation complete!"

# List created files
echo "Created files:"
ls -1 "$PROJECTS_DIR"/*.mdx | grep -v konut-projeleri | grep -v ticari-projeler | sort