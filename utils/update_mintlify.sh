#!/bin/bash

# PostgreSQL connection string
DB_URL='postgresql://neondb_owner:npg_lUi6Yw0OPjsq@ep-small-silence-agjg0s9s-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'

# Get all projects and update mintlify JSON with cloudinary images
psql "$DB_URL" << 'EOF'
DO $$
DECLARE
    project_record RECORD;
    updated_mintlify jsonb;
    image_urls jsonb := '[]'::jsonb;
BEGIN
    -- Loop through all projects
    FOR project_record IN
        SELECT id, project_name, slug, cloudinary_images, mintlify
        FROM projects
        WHERE cloudinary_images IS NOT NULL
        ORDER BY id
    LOOP
        -- Extract secure_urls from cloudinary_images
        SELECT jsonb_agg(img->'secure_url')
        INTO image_urls
        FROM jsonb_array_elements(project_record.cloudinary_images) AS img
        WHERE img ? 'secure_url';

        -- Create or update mintlify JSON
        IF project_record.mintlify IS NULL THEN
            updated_mintlify := jsonb_build_object(
                'url', 'https://architect.hamdierdogan.com/projeler/' || project_record.slug,
                'slug', project_record.slug,
                'images', COALESCE(image_urls, '[]'::jsonb)
            );
        ELSE
            updated_mintlify := project_record.mintlify ||
                jsonb_build_object('images', COALESCE(image_urls, '[]'::jsonb));
        END IF;

        -- Update the project
        UPDATE projects
        SET mintlify = updated_mintlify
        WHERE id = project_record.id;

        RAISE NOTICE 'Updated %: % images', project_record.project_name, jsonb_array_length(COALESCE(image_urls, '[]'::jsonb));
    END LOOP;
END $$;

SELECT id, project_name, jsonb_array_length(mintlify->'images') as image_count
FROM projects
WHERE mintlify->'images' IS NOT NULL
ORDER BY id;
EOF

echo "Mintlify JSON updated successfully!"