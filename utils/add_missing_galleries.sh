#!/bin/bash

# PostgreSQL connection string
DB_URL='postgresql://neondb_owner:npg_lUi6Yw0OPjsq@ep-small-silence-agjg0s9s-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'

# Add galleries for specific missing projects
echo "Adding galleries for missing projects..."

# Palmarina
echo "Processing Palmarina..."
psql "$DB_URL" -t -A -F'||' << 'EOF' | while IFS='||' read -r url; do echo "$url"; done > /tmp/palmarina_images.txt
SELECT img->>'secure_url'
FROM projects p, jsonb_array_elements(p.cloudinary_images) AS img
WHERE p.slug = 'palmarina'
    AND img->>'secure_url' IS NOT NULL
ORDER BY
    CASE
        WHEN img->>'public_id' ~ '^[0-9]+$' THEN LPAD(img->>'public_id', 10, '0')
        ELSE img->>'public_id'
    END;
EOF

if [ -s /tmp/palmarina_images.txt ]; then
    GALLERY_CONTENT="

## Proje Görselleri

<CardGroup cols={2}>"

    IMAGE_NUM=1
    while IFS= read -r url; do
        if [ -n "$url" ]; then
            secure_url="${url/http:/https:}"
            GALLERY_CONTENT="$GALLERY_CONTENT
  <Card>
    <img
      src=\"$secure_url\"
      alt=\"Palmarina Personel Lojman Blokları - Görsel $IMAGE_NUM\"
      className=\"w-full h-auto rounded-lg shadow-lg\"
      loading=\"lazy\"
    />
  </Card>"
            ((IMAGE_NUM++))
        fi
    done < /tmp/palmarina_images.txt

    GALLERY_CONTENT="$GALLERY_CONTENT
</CardGroup>"

    echo "$GALLERY_CONTENT" >> projeler/palmarina-personel-lojman-bloklari.mdx
    echo "  Added $((IMAGE_NUM - 1)) images to palmarina-personel-lojman-bloklari.mdx"
fi

# Troya Muzesi
echo "Processing Troya Muzesi..."
psql "$DB_URL" -t -A -F'||' << 'EOF' | while IFS='||' read -r url; do echo "$url"; done > /tmp/troya_images.txt
SELECT img->>'secure_url'
FROM projects p, jsonb_array_elements(p.cloudinary_images) AS img
WHERE p.slug = 'troya'
    AND img->>'secure_url' IS NOT NULL
ORDER BY
    CASE
        WHEN img->>'public_id' ~ '^[0-9]+$' THEN LPAD(img->>'public_id', 10, '0')
        ELSE img->>'public_id'
    END;
EOF

if [ -s /tmp/troya_images.txt ]; then
    GALLERY_CONTENT="

## Proje Görselleri

<CardGroup cols={2}>"

    IMAGE_NUM=1
    while IFS= read -r url; do
        if [ -n "$url" ]; then
            secure_url="${url/http:/https:}"
            GALLERY_CONTENT="$GALLERY_CONTENT
  <Card>
    <img
      src=\"$secure_url\"
      alt=\"Troya Müzesi Mimari Proje Yarışması - Görsel $IMAGE_NUM\"
      className=\"w-full h-auto rounded-lg shadow-lg\"
      loading=\"lazy\"
    />
  </Card>"
            ((IMAGE_NUM++))
        fi
    done < /tmp/troya_images.txt

    GALLERY_CONTENT="$GALLERY_CONTENT
</CardGroup>"

    echo "$GALLERY_CONTENT" >> projeler/troya-muzesi-mimari-proje-yarismasi.mdx
    echo "  Added $((IMAGE_NUM - 1)) images to troya-muzesi-mimari-proje-yarismasi.mdx"
fi

# Sahiller için Modüler Büfe
echo "Processing Sahiller için Modüler Büfe..."
psql "$DB_URL" -t -A -F'||' << 'EOF' | while IFS='||' read -r url; do echo "$url"; done > /tmp/sahiller_images.txt
SELECT img->>'secure_url'
FROM projects p, jsonb_array_elements(p.cloudinary_images) AS img
WHERE p.slug = 'sahiller-icin-moduler'
    AND img->>'secure_url' IS NOT NULL
ORDER BY
    CASE
        WHEN img->>'public_id' ~ '^[0-9]+$' THEN LPAD(img->>'public_id', 10, '0')
        ELSE img->>'public_id'
    END;
EOF

if [ -s /tmp/sahiller_images.txt ]; then
    GALLERY_CONTENT="

## Proje Görselleri

<CardGroup cols={2}>"

    IMAGE_NUM=1
    while IFS= read -r url; do
        if [ -n "$url" ]; then
            secure_url="${url/http:/https:}"
            GALLERY_CONTENT="$GALLERY_CONTENT
  <Card>
    <img
      src=\"$secure_url\"
      alt=\"Sahiller İçin Modüler Büfe Tasarımı - Görsel $IMAGE_NUM\"
      className=\"w-full h-auto rounded-lg shadow-lg\"
      loading=\"lazy\"
    />
  </Card>"
            ((IMAGE_NUM++))
        fi
    done < /tmp/sahiller_images.txt

    GALLERY_CONTENT="$GALLERY_CONTENT
</CardGroup>"

    echo "$GALLERY_CONTENT" >> projeler/sahiller-icin-moduler-bufe-tasarimi.mdx
    echo "  Added $((IMAGE_NUM - 1)) images to sahiller-icin-moduler-bufe-tasarimi.mdx"
fi

echo "Missing galleries added successfully!"