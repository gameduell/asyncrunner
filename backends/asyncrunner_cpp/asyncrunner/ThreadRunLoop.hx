/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 03/07/14
 * Time: 19:16
 */
package asyncrunner;

import cpp.vm.Thread;
import asyncrunner.Priority;
import asyncrunner.RunLoop;

class ThreadRunLoop extends RunLoop
{
    public var boundThread : Thread;

    public var isSleeping : Bool;

    private function wakeUpIfSleeping()
    {
        if(isSleeping)
        {
            boundThread.sendMessage(null);
        }
    }

    public function getCurrentLoad() : Int
    {
        return queuedFunctions.size() + queuedASAPFunctions.size();
    }

    override function queue(func : Dynamic, priority : Priority) : Void
    {
        super.queue(func, priority);

        if(isSleeping)
        {
            boundThread.sendMessage(null);
        }
    }

    override function queue1(func : Dynamic, param : Dynamic, priority : Priority) : Void
    {
        super.queue1(func, param, priority);

        if(isSleeping)
        {
            boundThread.sendMessage(null);
        }
    }

    override function queue2(func : Dynamic, param1 : Dynamic, param2 : Dynamic, priority : Priority) : Void
    {
        super.queue2(func, param1, param2, priority);

        if(isSleeping)
        {
            boundThread.sendMessage(null);
        }
    }

    override function queue3(func : Dynamic, param1 : Dynamic, param2 : Dynamic, param3 : Dynamic, priority : Priority) : Void
    {
        super.queue3(func, param1, param2, param3, priority);

        if(isSleeping)
        {
            boundThread.sendMessage(null);
        }
    }


    override function queue4(func : Dynamic, param1 : Dynamic, param2 : Dynamic, param3 : Dynamic, param4 : Dynamic, priority : Priority) : Void
    {
        super.queue4(func, param1, param2, param3, param4, priority);

        if(isSleeping)
        {
            boundThread.sendMessage(null);
        }
    }




}