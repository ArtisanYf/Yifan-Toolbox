class_name TextureUtil
extends RefCounted


# 生成 Texture
static func create_texture(path: String) -> ImageTexture:
	var image = Image.new()
	var error = image.load(path)
	if error == Error.OK:
		#image.convert(Image.FORMAT_RGBA8)  
		#image.resize(220,132.75)
		#image.resize(1280, 720)
		return ImageTexture.create_from_image(image)
	return null
