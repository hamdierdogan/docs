#!/bin/bash

# PostgreSQL connection string
DB_URL='postgresql://neondb_owner:npg_lUi6Yw0OPjsq@ep-small-silence-agjg0s9s-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'

# Get all projects with their images and tags
echo "Fetching all projects from database..."

psql "$DB_URL" -t -A -F'|' << 'EOF' | while IFS='|' read -r project_name slug mdx_file images; do
SELECT
    p.project_name,
    p.slug,
    CASE
        -- Map database slugs to MDX filenames
        WHEN p.slug = '2e-evi' THEN '2e-evi.mdx'
        WHEN p.slug = 'akkor-evi' THEN 'akkor-evi-gumusluk.mdx'
        WHEN p.slug = 'binnaz-karakaya' THEN 'binnaz-karakaya-kapali-yuzme-havuzu.mdx'
        WHEN p.slug = 'bodrum-gsl' THEN 'bodrum-guzel-sanatlar-fakultesi-seramik-bolumu.mdx'
        WHEN p.slug = 'koyuncuoglu' THEN 'koyuncuoglu-is-merkezi.mdx'
        WHEN p.slug = 'nimet-evi' THEN 'nimet-evi.mdx'
        WHEN p.slug = 'ole-olesen-evi' THEN 'ole-olesen-evi.mdx'
        WHEN p.slug = 'oranio-homes' THEN 'oranio-homes.mdx'
        WHEN p.slug = 'palmarina' THEN 'palmarina-personel-lojman-bloklari.mdx'
        WHEN p.slug = 'sahiller-icin-moduler' THEN 'sahiller-icin-moduler-bufe-tasarimi.mdx'
        WHEN p.slug = 'sp-evi' THEN 'sp-evi-bitez.mdx'
        WHEN p.slug = 'troya' THEN 'troya-muzesi-mimari-proje-yarismasi.mdx'
        WHEN p.slug = 'turkbuku-modern' THEN 'turkbuku-modern.mdx'
        WHEN p.slug = 'villa-deka' THEN 'villa-deka.mdx'
        WHEN p.slug = 'yalikavak-marina' THEN 'yalikavak-marina.mdx'
        WHEN p.slug = 'yener-evi' THEN 'yener-evi.mdx'
        WHEN p.slug = 'yunus-buyukkusoglu' THEN 'yunus-buyukkusoglu-ilkogretim-okulu.mdx'
        -- For others, try common patterns
        WHEN p.slug LIKE '%-%' THEN p.slug || '.mdx'
        ELSE p.slug || '.mdx'
    END as mdx_file,
    -- Get all secure_urls from cloudinary_images as a pipe-separated list
    (
        SELECT string_agg(img->>'secure_url', '||' ORDER BY
            CASE
                WHEN img->>'public_id' ~ '^[0-9]+$' THEN LPAD(img->>'public_id', 10, '0')
                ELSE img->>'public_id'
            END
        )
        FROM jsonb_array_elements(p.cloudinary_images) AS img
        WHERE img->>'secure_url' IS NOT NULL
    ) as images
FROM projects p
WHERE p.cloudinary_images IS NOT NULL
    AND p.cloudinary_images != '[]'::jsonb
    AND EXISTS (
        SELECT 1 FROM jsonb_array_elements(p.cloudinary_images) AS img
        WHERE img->>'secure_url' IS NOT NULL
    )
ORDER BY p.project_name;
EOF

    if [ -z "$images" ]; then
        echo "  No images for $project_name"
        continue
    fi

    MDX_PATH="projeler/$mdx_file"

    if [ ! -f "$MDX_PATH" ]; then
        echo "  File not found: $MDX_PATH"
        continue
    fi

    echo "Processing $project_name -> $MDX_PATH"

    # Create gallery content
    GALLERY_CONTENT="

## Proje Görselleri

<CardGroup cols={2}>"

    # Convert pipe-separated URLs to array and add each image
    IFS='||' read -ra IMAGE_ARRAY <<< "$images"
    IMAGE_NUM=1
    for url in "${IMAGE_ARRAY[@]}"; do
        if [ -n "$url" ]; then
            # Convert http to https
            secure_url="${url/http:/https:}"

            GALLERY_CONTENT="$GALLERY_CONTENT
  <Card>
    <img
      src=\"$secure_url\"
      alt=\"$project_name - Görsel $IMAGE_NUM\"
      className=\"w-full h-auto rounded-lg shadow-lg\"
      loading=\"lazy\"
    />
  </Card>"
            ((IMAGE_NUM++))
        fi
    done

    GALLERY_CONTENT="$GALLERY_CONTENT
</CardGroup>"

    # Append gallery to the MDX file
    echo "$GALLERY_CONTENT" >> "$MDX_PATH"
    echo "  Added $((IMAGE_NUM - 1)) images to $MDX_PATH"

done

echo "Gallery rebuild complete!"