/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/07/14
 * Time: 09:17
 */

import asyncrunner.Task;
import haxe.Timer;
import asyncrunner.RunLoop;
import graphics.TextureData;
import graphics.Graphics;
import graphics.Shader;
import graphics.MeshData;
import graphics.GraphicsTypes;
import asyncrunner.ParallelTaskGroup;
import asyncrunner.FunctionTask;
import asyncrunner.SequentialTaskGroup;

import types.DataInputStream;
import types.Color4B;
import media.bitmap.BitmapData;
import media.bitmap.png.BitmapDataPNGFactory;
import types.DataOutputStream;
import filesystem.Filesystem;
import filesystem.FileReader;

import types.DataType;
import types.Data;
import types.Matrix4;

class TexturedUnlit
{
    public static var vertexCode = "

	attribute highp vec4 a_Position;
	attribute lowp vec2 a_TexCoord;
	uniform highp mat4 u_MVP;

	varying lowp vec2 v_TexCoord;
	void main() {
		gl_Position =  u_MVP * vec4(a_Position.xyz, 1.0);
		v_TexCoord = a_TexCoord;
	}
	";

    public static var fragmentCode = "
	uniform sampler2D s_Texture;
	varying lowp vec2 v_TexCoord;

	void main() {
		gl_FragColor = texture2D(s_Texture, v_TexCoord);
	}
	";
}

class Sprite
{
    private var graphics : Graphics;

    static private var shader : Shader;
    static private var shaderLoaded : Bool;
    static private var mvpInterface : ShaderUniformInterface;
    static private var textureInterface : ShaderUniformInterface;

    private var meshData : MeshData;

    private var texture : TextureData;

    private var filename : String;

    public function new(filename : String) : Void
    {
        graphics = Graphics.instance();
        this.filename = filename;
    }

    public function getLoadingTask() : Task
    {
        var createTextureTask = new FunctionTask(createTexture);
        createTextureTask.runLoopForExecution = RunLoop.getPooledLoop();

        var createShadersTask = new FunctionTask(createShaders);
        createShadersTask.runLoopForExecution = RunLoop.getPooledLoop();

        var createBuffersTask = new FunctionTask(createBuffers);
        createBuffersTask.runLoopForExecution = RunLoop.getPooledLoop();

        var loadShaderTask = new FunctionTask(loadShader);

        var loadTextureTask = new FunctionTask(loadTextureData);

        var loadMeshTask = new FunctionTask(loadMeshData);

        var fullLoadingTask = new SequentialTaskGroup([
                                        createTextureTask, createShadersTask,
                                        createBuffersTask,loadShaderTask ,loadTextureTask,
                                        loadMeshTask]);

        fullLoadingTask.data = this;
        return fullLoadingTask;
    }

    public function render(mvpMatrix : Matrix4)
    {
        mvpInterface.data.writeData(mvpMatrix.data);
        mvpInterface.dataActiveCount = 1;
        textureInterface.data.writeInt(1, DataTypeInt32);
        graphics.bindShader(shader);
        graphics.bindTextureData(texture, 1);
        graphics.bindMeshData(meshData, 0);
        graphics.render(meshData, 0);

    }



    private function createBuffers () : Void
    {
        meshData = new MeshData();

        var halfwidth = texture.originalWidth / 2.0;
        var halfheight = texture.originalHeight / 2.0;
        halfwidth *= 0.5;
        halfheight *= 0.5;

        var vertices = [

        -halfwidth,     -halfheight,    0.0,	0.0,	0.0,	0.0,
        halfwidth,      -halfheight,    0.0,	0.0,	1.0,	0.0,
        -halfwidth,     halfheight,		0.0,	0.0,	0.0,	1.0,
        -halfwidth,     halfheight,		0.0,	0.0,	0.0,	1.0,
        halfwidth,      -halfheight,    0.0,	0.0,	1.0,	0.0,
        halfwidth,      halfheight,		0.0,	0.0,	1.0,	1.0
        ];

        var attributeBuffer = new MeshDataBuffer();
        meshData.attributeBuffer = attributeBuffer;

        attributeBuffer.bufferMode = BufferModeStaticDraw;
        attributeBuffer.data = new Data(vertices.length * 4);
        attributeBuffer.data.writeFloatArray(vertices, DataTypeFloat32);

        meshData.vertexCount = 6;
        meshData.primitiveType = PrimitiveTypeTriangles;
        meshData.indexDataType = DataTypeFloat32;
        meshData.attributeStride = 6 * 4;

        var posAttributeConfig = new MeshDataAttributeConfig();
        posAttributeConfig.attributeNumber = 0;
        posAttributeConfig.offsetInData = 0;
        posAttributeConfig.vertexElementCount = 4;
        posAttributeConfig.vertexElementsNormalized = false;
        posAttributeConfig.vertexElementType = DataTypeFloat32;

        var uvAttributeConfig = new MeshDataAttributeConfig();
        uvAttributeConfig.attributeNumber = 1;
        uvAttributeConfig.offsetInData = 4 * 4;
        uvAttributeConfig.vertexElementCount = 2;
        uvAttributeConfig.vertexElementsNormalized = false;
        uvAttributeConfig.vertexElementType = DataTypeFloat32;

        meshData.attributeConfigs = [posAttributeConfig, uvAttributeConfig];

    }


    private function createShaders ():Void
    {
        if(shader != null)
            return;

        shaderLoaded = false;
        /// should check the cache, etc, just like this™ for now
        shader = new Shader();

        shader.name = "TestShader";

        shader.vertexShaderCode = TexturedUnlit.vertexCode;
        shader.fragmentShaderCode = TexturedUnlit.fragmentCode;

        mvpInterface = new ShaderUniformInterface();
        mvpInterface.setup("u_MVP", UniformTypeMatrix4, 1);

        textureInterface = new ShaderUniformInterface();
        textureInterface.setup("s_Texture", UniformTypeSingleInt, 1);

        shader.uniformInterfaces = [textureInterface, mvpInterface];
        shader.attributeNames = ["a_Position", "a_TexCoord"];

    }

    private function createTexture ():Void
    {
        texture = new TextureData();
        var reader : FileReader = Filesystem.instance().getFileReader(Filesystem.instance().urlToStaticData() + "/" + filename);

        var initialPosition = reader.seekPosition;
        reader.seekEndOfFile();
        var fileSize = reader.seekPosition - initialPosition;
        reader.seekPosition = initialPosition;

        var data = new Data(fileSize);

        reader.readIntoData(data);

        var inputStream = new DataInputStream(data);

        var bitmapData : BitmapData = BitmapDataPNGFactory.decodeStream(inputStream);

        texture.data = bitmapData.data;

        texture.originalWidth = bitmapData.width;
        texture.originalHeight = bitmapData.height;

        texture.filteringMode = TextureFilteringModeLinear;
        texture.hasAlpha = true;
        texture.hasMipMaps = false;
        texture.wrap = TextureWrapClamp;
        texture.hasPremultipliedAlpha = true;
        texture.pixelFormat = TextureFormatRGBA8888;
        texture.textureType = TextureType2D;

    }

    private function loadShader()
    {
        if(!shaderLoaded)
            graphics.loadFilledShader(shader);
    }

    private function loadMeshData()
    {
        graphics.loadFilledMeshData(meshData);
    }

    private function loadTextureData()
    {
        var initialTime = Timer.stamp();
        graphics.loadFilledTextureData(texture);
    }



}