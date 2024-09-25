module vulkan.utils.SpriteSheet;

import vulkan.all;

/**
 * Simple sprite sheet utility. 
 *
 * Assumes:
 *  - The sprite sheet is a square
 *  - All of the images have 4 components per pixel
 *  - All images are the same size
 *  - The resulting sprite sheet image is written as a BMP
 */
final class SpriteSheet {
public:
    this(uint width, uint height) {
        this.width = width;
        this.height = height;
    }
    void addImage(string key, string filename) {
        Image image = Image.read(filename);
        images[key] = image;

        throwIf(image.width > this.width, "Image width %s > %s", image.width, this.width);
        throwIf(image.height > this.height, "Image height %s > %s", image.height, this.height); 
    }
    void saveImageTo(string filename) {
        generate();
        spriteSheetImage.write(filename);
    }
    float4[string] getUVs() {
        return uvs;
    }
private:
    uint width;
    uint height;
    Image[string] images;

    BMP spriteSheetImage;
    float4[string] uvs;

    void generate() {
        static struct Item {
            string key;
            Image image;
            uint size() { return image.width*image.height; }
            string toString() { return "%s %sx%s".format(key, image.width, image.height); }
        }
        Item[] orderedBySize = images.byKeyValue()
                                     .map!(e=>Item(e.key,e.value))
                                     .array();

        orderedBySize.sort!((a,b) => a.size() > b.size());

        this.log("sorted = %s", orderedBySize);

        uint x,y;
        float fwidth = width.as!float;
        float fheight = height.as!float;

        // Create the sprite sheet image
        this.spriteSheetImage = BMP.create_RGBA8888(width, height);

        // Simple algorithm:
        // - Assume all images are the same size
        // - Assume: All images are RGBA
        foreach(sprite; orderedBySize) {
            auto w = sprite.image.width;
            auto h = sprite.image.height;

            throwIf(sprite.image.bytesPerPixel != 4);
            
            while(true) {
                if(x+w <= width) {
                    uvs[sprite.key] = float4(x/fwidth, y/fheight, (x+w)/fwidth, (y+h)/fheight);
                    copyToSpriteSheet(sprite.image, x, y);
                    x += w;
                    break;
                } else if(y+h <= height) {
                    // move down
                    y += h;
                    x = 0;
                } else {
                    throwIf(true, "Run out of space on the sprite sheet image x = %s, y = %s", x, y);
                }
            }
        }
    }

    void copyToSpriteSheet(Image srcImage, uint sx, uint sy) {
        //this.log("Copying %s,%s -> %s,%s", srcImage.width, srcImage.height, sx, sy);

        foreach(y; 0..srcImage.height) {
            
            uint src  = y*srcImage.width*4;
            ubyte[] data = srcImage.data;

            foreach(x; 0..srcImage.width) {
                spriteSheetImage.set(sx+x, sy+y, data[src], data[src+1], data[src+2], data[src+3]);
                src  += 4;
            }
        }
    }
}
