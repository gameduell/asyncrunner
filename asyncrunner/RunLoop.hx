/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 12/06/14
 * Time: 16:09
 */

package asyncrunner;

import de.polygonal.ds.LinkedQueue;
import haxe.Timer;

#if cpp
import cpp.vm.Thread;
#end

class RunLoop
{

    #if cpp

    static private var runLoopInstancesPerThread : Map<Dynamic, RunLoop >;

    #else

    static private var singleRunLoopInstance : RunLoop;

    #end

    private var queuedFunctions : LinkedQueue<Dynamic>;
    private var queuedParams : LinkedQueue< Dynamic >;
    private var queuedParamCount : LinkedQueue<Int>;

    private var queuedASAPFunctions : LinkedQueue<Dynamic>;
    private var queuedASAPParams : LinkedQueue< Dynamic >;
    private var queuedASAPParamCount : LinkedQueue<Int>;

    #if cpp

    static public function getLoopForThread(thread : Thread) : RunLoop
    {
        if(runLoopInstancesPerThread == null ||
           !runLoopInstancesPerThread.exists(thread.handle))
        {
            return null;
        }
        else
        {
            return runLoopInstancesPerThread[thread.handle];
        }
    }

    #end

    static public function getCurrentLoop() : RunLoop
    {

        #if cpp

        return getLoopForThread(Thread.current());

        #else

        return singleRunLoopInstance;

        #end
    }


    public function new()
    {
        #if cpp

        if(runLoopInstancesPerThread == null)
             runLoopInstancesPerThread = new Map<Dynamic, RunLoop >();

        if(!runLoopInstancesPerThread.exists(Thread.current().handle))
        {
            runLoopInstancesPerThread.set(Thread.current().handle, this);
        }
        else
        {
            throw "Only one RunLoop is allowed per thread. Use RunLoop.getCurrentLoop() to get the current one.";
        }

        #else

        if(singleRunLoopInstance != null)
        {
            throw "Only one RunLoop is allowed. Use RunLoop.getCurrentLoop() to get the current one.";
        }
        singleRunLoopInstance = this;

        #end

        queuedFunctions = new LinkedQueue();
        queuedParams = new LinkedQueue();
        queuedParamCount = new LinkedQueue();

        queuedASAPFunctions = new LinkedQueue();
        queuedASAPParams = new LinkedQueue();
        queuedASAPParamCount = new LinkedQueue();
    }

    public function loopOnce(timeLimit : Float)
    {
        var initialTime : Float = Timer.stamp ();

        var timeLeft = timeLimit;

        var asapFunctionCount = queuedASAPFunctions.size();

        /// execute all asap functions

        while(asapFunctionCount > 0)
        {
            doOneASAPPriorityFunction();
            --asapFunctionCount;
        }

        /// execute 1 low prio function, and as much as possible for the time limit

        var lowPrioFunctionCount = queuedASAPFunctions.size();

        if(lowPrioFunctionCount == 0)
            return;

        doOneLowPriorityFunction();
        --lowPrioFunctionCount;

        var timeAfterASAPAndOneLowPrio = Timer.stamp();
        timeLeft -= timeAfterASAPAndOneLowPrio - initialTime;

        /// execute remaining low prios for as much as the time limit allows

        var timeBeforeOneLowPrio = Timer.stamp();
        while(timeLeft > 0 && lowPrioFunctionCount > 0)
        {
            doOneLowPriorityFunction();

            var newTime = Timer.stamp();
            timeLeft -= newTime - timeBeforeOneLowPrio;
            timeBeforeOneLowPrio = newTime;

            --lowPrioFunctionCount;
        }
    }

    /// run loop instance will be garbage collected after this, if it's not held somewhere
    public function terminate()
    {
        #if cpp

        for(key in runLoopInstancesPerThread.keys())
        {
            if(runLoopInstancesPerThread[key] == this)
            {
                runLoopInstancesPerThread.remove(key);
                break;
            }
        }

        #else

        singleRunLoopInstance = null;

        #end
    }

    private function doOneLowPriorityFunction()
    {
        var func = queuedFunctions.dequeue();

        var paramCount = queuedParamCount.dequeue();

        switch(paramCount)
        {
            case (0):
                func();
            case (1):
                func(queuedParams.dequeue());
            case (2):
                func(queuedParams.dequeue(), queuedParams.dequeue());
            case (3):
                func(queuedParams.dequeue(), queuedParams.dequeue(), queuedParams.dequeue());
            case (4):
                func(queuedParams.dequeue(), queuedParams.dequeue(), queuedParams.dequeue(), queuedParams.dequeue());

        }
    }

    private function doOneASAPPriorityFunction()
    {
        var func = queuedASAPFunctions.dequeue();

        var paramCount = queuedASAPParamCount.dequeue();

        switch(paramCount)
        {
            case (0):
                func();
            case (1):
                func(queuedASAPParams.dequeue());
            case (2):
                func(queuedASAPParams.dequeue(), queuedASAPParams.dequeue());
            case (3):
                func(queuedASAPParams.dequeue(), queuedASAPParams.dequeue(), queuedASAPParams.dequeue());
            case (4):
                func(queuedASAPParams.dequeue(), queuedASAPParams.dequeue(), queuedASAPParams.dequeue(), queuedASAPParams.dequeue());

        }
    }

    public function queue(func : Dynamic, priority : Priority) : Void
    {
        switch(priority)
        {
            case(PriorityASAP):
                queuedASAPFunctions.enqueue(func);
                queuedASAPParamCount.enqueue(0);
            case(PriorityLow):
                queuedFunctions.enqueue(func);
                queuedParamCount.enqueue(0);
        }
    }

    public function queue1(func : Dynamic, param : Dynamic, priority : Priority) : Void
    {
        switch(priority)
        {
            case(PriorityASAP):
                queuedASAPFunctions.enqueue(func);
                queuedASAPParamCount.enqueue(1);
                queuedASAPParams.enqueue(param);
            case(PriorityLow):
                queuedFunctions.enqueue(func);
                queuedParamCount.enqueue(1);
                queuedParams.enqueue(param);
        }
    }

    public function queue2(func : Dynamic, param1 : Dynamic, param2 : Dynamic, priority : Priority) : Void
    {
        switch(priority)
        {
            case(PriorityASAP):
                queuedASAPFunctions.enqueue(func);
                queuedASAPParamCount.enqueue(2);
                queuedASAPParams.enqueue(param1);
                queuedASAPParams.enqueue(param2);
            case(PriorityLow):
                queuedFunctions.enqueue(func);
                queuedParamCount.enqueue(2);
                queuedParams.enqueue(param1);
                queuedParams.enqueue(param2);
        }
    }

    public function queue3(func : Dynamic, param1 : Dynamic, param2 : Dynamic, param3 : Dynamic, priority : Priority) : Void
    {
        switch(priority)
        {
            case(PriorityASAP):
                queuedASAPFunctions.enqueue(func);
                queuedASAPParamCount.enqueue(3);
                queuedASAPParams.enqueue(param1);
                queuedASAPParams.enqueue(param2);
                queuedASAPParams.enqueue(param3);
            case(PriorityLow):
                queuedFunctions.enqueue(func);
                queuedParamCount.enqueue(3);
                queuedParams.enqueue(param1);
                queuedParams.enqueue(param2);
                queuedParams.enqueue(param3);
        }
    }


    public function queue4(func : Dynamic, param1 : Dynamic, param2 : Dynamic, param3 : Dynamic, param4 : Dynamic, priority : Priority) : Void
    {
        switch(priority)
        {
            case(PriorityASAP):
                queuedASAPFunctions.enqueue(func);
                queuedASAPParamCount.enqueue(4);
                queuedASAPParams.enqueue(param1);
                queuedASAPParams.enqueue(param2);
                queuedASAPParams.enqueue(param3);
                queuedASAPParams.enqueue(param4);
            case(PriorityLow):
                queuedFunctions.enqueue(func);
                queuedParamCount.enqueue(4);
                queuedParams.enqueue(param1);
                queuedParams.enqueue(param2);
                queuedParams.enqueue(param3);
                queuedParams.enqueue(param4);
        }
    }
}