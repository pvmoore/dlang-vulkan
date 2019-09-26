#### Implementing printf inside compute shaders

This is a simple example without quoted strings of text inside the shader.
In order to have quoted strings, a pre-processing stage is required.

##### Inside the shader:
```glsl
// ==============================================  printf start
 layout(set=1, binding=0, std430) writeonly buffer PRINTF_BUFFER {
	float buf[];
 } printf;
 layout(set=1, binding=1, std430) buffer PRINTF_STATS {
   uint buf[];
 } printf_stats;
 #include "_printf.inc"
// ============================================== printf end
```
`printf_buffer[0]` is the num `uint`s written to the buffer by the shader.

Inside _printf.inc:
```glsl
// print uint example method
void print(uint v) {
    // use atomicAdd here if you want to call this from
    // more than 1 shader instance. probably not that useful though.
    uint i = printf.buf[0];
    printf.buf[0] = i + 2;

    printf.buf[i]   = 1; // uint type
    printf.buf[i+1] = v;
}
void printc(uint v) {
    // print a char
}
```
Where type is one of:

| Type bits(0-3) | Value  | Value Size(in uints per component) |
|------|--------|---|
| 0    | bool   | 1 |
| 1    | uint   | 1 |
| 2    | int    | 1 |
| 3    | float  | 1 |
| 4    | ulong  | 2 |
| 5    | long   | 2 |
| 6    | char   | 1 |

Type bits 0-3 (16 possible types) are shown in the table above.
Type bits 4-7 contains the number of values -1.

eg.
- type = `1` is a single uint
- type = `1|(1<<4)` is a uvec2
- type = `3|(15<<4)` is a mat4 of 16 floats

Half and double are not supported.
Floats will be packed using floatBitsToUint.

##### In the vulkan code:
- Use a DS layout and DS that includes a buffer of sufficient size.
- Read buffer back after shader has executed.
- Parse buffer and print contents.

##### Possible improvement:
Use a pre-processor (eg. compile_spirv.d) to modify the source before
sending it to spirv. For example, rewriting quoted text to calls to
printc. Could even implement a full printf.
