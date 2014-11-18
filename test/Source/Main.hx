
import asyncrunner.Task;
import asyncrunner.FunctionTask;
import asyncrunner.SequentialTaskGroup;
import graphics.TextureData;
import graphics.Graphics;
import graphics.Shader;
import graphics.MeshData;
import graphics.GraphicsTypes;

import haxe.Timer;

import types.DataType;
import types.Data;
import types.Matrix4;
import types.Color4B;

import StringTools;

import platform.Platform;
import platform.AppMain;



class Main extends AppMain
{

	private var deltaPerFrame:Float;
	private var currentTime:Float;


    private var projectionMatrix : Matrix4;
    private var rotationMatrix : Matrix4;
    private var worldMatrix : Matrix4;
    private var resultMatrix : Matrix4;
    private var positionMatrix : Matrix4;


	private var graphics : Graphics;

    private var spriteList : Array<Sprite>;

    static var gridSizeX = 10;
    static var gridSizeY = 10;


	override function start() : Void 
	{
        Graphics.initialize(startAfterGraphicsIsInitialized);

        spriteList = new Array<Sprite>();
	}

    private function startAfterGraphicsIsInitialized() : Void
    {
        graphics = Graphics.instance();

        projectionMatrix = new Matrix4();
        projectionMatrix.setOrtho (0, Platform.instance().screenWidth, Platform.instance().screenHeight, 0, -1024, 1024);

        rotationMatrix = new Matrix4();
        rotationMatrix.setIdentity();

        positionMatrix = new Matrix4();
        positionMatrix.setIdentity();

        resultMatrix = new Matrix4();
        resultMatrix.setIdentity();

        worldMatrix = new Matrix4();
        worldMatrix.setIdentity();

        graphics.setBlendFunc(BlendFactorSrcAlpha, BlendFactorOneMinusSrcAlpha);

        currentTime = Timer.stamp();

        var fileList = ["player1.png", 
                        "player2.png", 
                        "player3.png", 
                        "player4.png", 
                        "player5.png", 
                        "player6.png", 
                        "player7.png", 
                        "player8.png", 
                        "player9.png", 
                        "player10.png", 
                        "player11.png", 
                        "player12.png", 
                        "player13.png"];

        var spriteLoadingTaskArray : Array< Task > = [];
        for(i in 0...gridSizeX * gridSizeY)
        {
            var fileIndex : Int = Std.random(fileList.length);
            var filename = fileList[fileIndex];
            var sprite = new Sprite(filename);

            var task = sprite.getLoadingTask();
            task.onFinish.add(spriteLoaded);
            spriteLoadingTaskArray.push(task);
        }


        new SequentialTaskGroup(spriteLoadingTaskArray).execute();

        Platform.instance().onRender.add(render);
    }



    private function spriteLoaded(task : Task)
    {
        spriteList.push(task.data);
    }


    static var startingX = 100;
    static var startingY = 100;
    static var deltaX = 100;
    static var deltaY = 100;
	private function render () : Void
	{
        var newCurrentTime : Float = Timer.stamp ();
        deltaPerFrame = newCurrentTime - currentTime;
        currentTime = newCurrentTime;

        graphics.clearColorBuffer();


        rotationMatrix.set2D(0, 0, 1, -100*deltaPerFrame);
        worldMatrix.multiply(rotationMatrix);

        for(i in 0...spriteList.length)
        {
            var sprite = spriteList[i];

            positionMatrix.set2D(startingX + (i / gridSizeX) * deltaX, startingY + (i % gridSizeY) * deltaY, 1, 0);

            resultMatrix.set(projectionMatrix);
            resultMatrix.multiply(positionMatrix);
            resultMatrix.multiply(worldMatrix);
            sprite.render(resultMatrix);
        }
	}

}