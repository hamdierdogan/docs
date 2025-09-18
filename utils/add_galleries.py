#!/usr/bin/env python3
"""
Script to add image galleries to MDX files from database
"""
import json

# Project mapping: slug -> mdx filename
PROJECT_MAPPING = {
    'troya-muzesi': 'troya-muzesi-mimari-proje-yarismasi',
    '2hevi': '2h-evi',
    'dk-evi-yaliciftlik-bodrum': 'dk-evi',
    'ende-mogol': 'ender-mogol-evi',
    'teni': 'teni-evleri',
    'eskisehir-ticaret-odasi': 'eskisehir-ticaret-odasi-ulusal-mimari-proje-yarismasi',
    'denizli-belediyesi-hizmet-binasi': 'denizli-belediyesi-hizmet-binasi-ve-cevresi-mimari-proje-yarismasi',
    'fethiye-belediyesi-alisveris-ve-yasam-merkezi': 'fethiye-belediyesi-alisveris-ve-yasam-merkezi-ulusal-mimari-proje-yarismasi',
    'buyuk-misir-muzesi': 'buyuk-misir-muzesi-mimari-proje-yarismasi',
    'sahil-moduler-bufe': 'sahiller-icin-moduler-bufe-tasarimi',
}

# Generate gallery HTML
def generate_gallery(project_name, images):
    gallery = '\n## Proje Görselleri\n\n<CardGroup cols={2}>\n'

    for i, img_url in enumerate(images, 1):
        gallery += f'''  <Card>
    <img
      src="{img_url}"
      alt="{project_name} - Görsel {i}"
      className="w-full h-auto rounded-lg shadow-lg"
      loading="lazy"
    />
  </Card>
'''

    gallery += '</CardGroup>\n'
    return gallery

print("Project mapping created. Use this to update MDX files with galleries.")