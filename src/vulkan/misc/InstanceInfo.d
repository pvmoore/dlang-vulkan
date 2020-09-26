module vulkan.misc.InstanceInfo;

import vulkan.all;

/**
 *  https://www.khronos.org/registry/vulkan/specs/1.0/man/html/vkEnumerateInstanceLayerProperties.html
 *  https://vulkan.lunarg.com/doc/view/1.0.46.0/windows/layers.html
 */
final class InstanceInfo {
private:
    VkLayerProperties[string] layers;
    VkExtensionProperties[string] extensions;
public:
    this() {
        enumerateLayers();
        enumerateExtensions();
    }
    bool hasLayer(string name) {
        return (name in layers) !is null;
    }
    bool hasExtension(string name) {
        return (name in extensions) !is null;
    }
    void dumpLayers() {
        log("Instance layers: %s", layers.length);
        foreach(i, l; layers.values()) {
            log("  [%s] layer name:'%s' desc:'%s' specVersion:%s implVersion:%s",
                i,
                l.layerName.ptr.fromStringz,
                l.description.ptr.fromStringz,
                versionToString(l.specVersion),
                l.implementationVersion);
        }
    }
    void dumpExtensions() {
        log("Instance extensions: %s", extensions.length);
        foreach(i, p; extensions.values()) {
            log("  [%s] extensionName:'%s' specVersion:%s",
                i,
                p.extensionName.ptr.fromStringz,
                p.specVersion);
        }
    }
private:
    void enumerateLayers() {
        uint count;
        vkEnumerateInstanceLayerProperties(&count, null);

        if(count>0) {
            auto array = new VkLayerProperties[count];
            vkEnumerateInstanceLayerProperties(&count, array.ptr);

            foreach(prop; array) {
                this.layers[prop.layerName.ptr.fromStringz.idup] = prop;
            }
        }
        log("layers = %s", layers);
    }
    void enumerateExtensions() {
        uint count;
        vkEnumerateInstanceExtensionProperties(null, &count, null);


        if(count>0) {
            auto array = new VkExtensionProperties[count];
            vkEnumerateInstanceExtensionProperties(null, &count, array.ptr);

            foreach(prop; array) {
                this.extensions[prop.extensionName.ptr.fromStringz.idup] = prop;
            }
        }
    }
}
