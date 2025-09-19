#!/bin/bash

# Neon database connection
DB_URL='postgresql://neondb_owner:npg_lUi6Yw0OPjsq@ep-small-silence-agjg0s9s-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'

# Projects directory
PROJECTS_DIR="/home/hamdierdogan/docs/projeler"

# Remove existing project MDX files (except index files)
echo "Removing existing project MDX files..."
find "$PROJECTS_DIR" -name "*.mdx" ! -name "konut-projeleri.mdx" ! -name "ticari-projeler.mdx" -delete

# Generate MDX files from Neon database
echo "Generating MDX files from Neon database..."

psql "$DB_URL" -t -A << 'EOF' | while IFS='|' read -r project_name slug images_json; do
SELECT
  project_name,
  slug,
  cloudinary_images::text
FROM projects
WHERE slug IS NOT NULL AND slug != ''
ORDER BY project_name;
EOF

  # Clean up slug for filename
  filename=$(echo "$slug" | sed 's/[^a-z0-9-]/-/g')
  mdx_file="$PROJECTS_DIR/${filename}.mdx"

  echo "Creating: $mdx_file"

  # Parse project name for title
  title=$(echo "$project_name" | sed 's/^\s*//;s/\s*$//')

  # Create MDX content
  cat > "$mdx_file" << MDXEOF
---
title: "$title"
description: "$title projesi"
---

# $title

<Frame>
MDXEOF

  # Add first image as hero image
  first_image=$(echo "$images_json" | jq -r '.[0].secure_url // empty' 2>/dev/null)
  if [ -n "$first_image" ]; then
    echo "  <img src=\"$first_image\" alt=\"$title\" />" >> "$mdx_file"
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
      <img src="$image_url" alt="$title" />
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
ls -la "$PROJECTS_DIR"/*.mdx | grep -v konut-projeleri | grep -v ticari-projeler