/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/07/14
 * Time: 12:04
 */
package asyncrunner;

import haxe.Timer;
import platform.Platform;
class MainRunLoop extends RunLoop
{
    public function new() : Void
    {
        Platform.instance().onUpdate.addWithPriority(onUpdate, 2147483647); /// MAX INT

        super();

        firstFrameHappened = false;
    }


    private var timeInTheBeginningOfTheFrame : Float;
    private var timeOnTheNextFrame : Float;
    private var firstFrameHappened : Bool;
    private function onUpdate(time : Float) : Void
    {
        timeOnTheNextFrame = Timer.stamp();
        if(!firstFrameHappened)
        {
            firstFrameHappened = true;
        }
        else
        {
            var timeUsed = timeOnTheNextFrame - timeInTheBeginningOfTheFrame;
            var timeLeft = (1.0 / 60.0) - timeUsed;
            loopOnce(timeLeft);

        }

        timeInTheBeginningOfTheFrame = timeOnTheNextFrame;
    }


}