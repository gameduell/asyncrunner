/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 04/07/14
 * Time: 12:04
 */
package asyncrunner;

import haxe.Timer;
class MainRunLoop extends RunLoop
{
    private var timeInTheBeginningOfTheFrame : Float;
    private var timeOnTheNextFrame : Float;
    private var firstLoopHappened : Bool;

    public function new() : Void
    {
        super();

        firstLoopHappened = false;
    }

    public function loopMainLoop(time : Float) : Void
    {
        timeOnTheNextFrame = Timer.stamp();
        if(!firstLoopHappened)
        {
            firstLoopHappened = true;
        }
        else
        {
            var timeUsed = timeOnTheNextFrame - timeInTheBeginningOfTheFrame;
            var timeLeft = (1.0 / 60.0) - timeUsed; /// 60 fps, should be a settable variable later
            loopOnce(timeLeft);

        }

        timeInTheBeginningOfTheFrame = timeOnTheNextFrame;
    }




}