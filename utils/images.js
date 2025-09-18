// Simple Cloudinary URL generator for project images
const CLOUD_NAME = 'dcc07g3za';
const CLOUDINARY_BASE = `https://res.cloudinary.com/${CLOUD_NAME}/image/upload`;

/**
 * Get a project image URL from Cloudinary
 * @param {string} projectSlug - The slug of the project
 * @param {string} imageName - The name of the image file (e.g., 'thumbnail.jpg')
 * @param {Object} options - Image transformation options
 * @returns {string} - Complete Cloudinary URL
 */
export const getProjectImage = (projectSlug, imageName = 'thumbnail.jpg', options = {}) => {
  const transformations = [];
  
  // Add transformations if provided
  if (options.width) transformations.push(`w_${options.width}`);
  if (options.height) transformations.push(`h_${options.height}`);
  if (options.crop) transformations.push(`c_${options.crop}`);
  if (options.quality) transformations.push(`q_${options.quality}`);
  
  // Default transformations
  if (transformations.length === 0) {
    transformations.push('q_auto,f_auto');
  }
  
  // Build the URL
  const transformStr = transformations.join(',');
  const imagePath = `projects/${projectSlug}/${imageName}`.toLowerCase();
  
  return `${CLOUDINARY_BASE}/${transformStr}/${imagePath}`;
};

/**
 * Get a project thumbnail URL
 * @param {string} projectSlug - The slug of the project
 * @returns {string} - Complete Cloudinary URL for the project thumbnail
 */
export const getProjectThumbnail = (projectSlug) => {
  return getProjectImage(projectSlug, 'thumbnail.jpg', {
    width: 800,
    height: 600,
    crop: 'fill',
    quality: 80
  });
};
