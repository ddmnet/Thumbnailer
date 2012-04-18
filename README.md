#Thumbnailer

##Overview
Provided a path to an image, allows a user to scale that image to a specified width while maintaining the aspect-ratio.

##Methods

`Thumbnailer.scale(sourcePath, pxWide, shouldOverwrite, callbackFunction)`

Scales an image to a specified width while preserving the aspect-ratio. The scaled images a stored in `Library/Caches/thumbnailer_image_cache` by default.

- sourcePath: The path to the source image
- pxWide: The desired width of the scaled image
- shouldOverwrite: Whether or not an existing thumbnail of the same name should be overwritten
- callbackFunction: Will return the thumbnail image's full path if successfull, otherwise `false`

`Thumbnailer.deleteAllImages()`

Removes thumbnailer_image_cache directory and its contents.