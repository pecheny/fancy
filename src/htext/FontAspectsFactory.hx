package htext;

import gl.aspects.TextureBinder;
import utils.TextureStorage;
import font.FontStorage;

class FontAspectsFactory {
	var fonts:FontStorage;
	var textureStorage:TextureStorage;

	public function new(fonts, textures) {
		this.fonts = fonts;
		this.textureStorage = textures;
	}

	public function getAlias(xml:Xml) {
		var fontName = xml.get("font");
		var font = fonts.getFont(fontName);
		if (font == null)
			throw 'there is no font $fontName';
		return font.getId();
	}

	public function create(xml:Xml) {
		var fontName = xml.get("font");
		var font = fonts.getFont(fontName);
		if (font == null)
			throw 'there is no font $fontName';
		return new TextureBinder(textureStorage, font.texturePath);
	}
}
