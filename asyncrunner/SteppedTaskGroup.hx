package asyncrunner;

import asyncrunner.Task;

class SteppedTaskGroup extends SequentialTaskGroup
{
    public var stepTasks (default, null): Array<Task>;

    private var blockingTasks: Array<BlockingTask>;
    private var currentStepIndex: Int;

    public function new(tasks: Array<Task>) : Void
    {
        currentStepIndex = 0;
        stepTasks = [];
        blockingTasks = [];

        var tasksToRun: Array<Task> = [];
        for (i in 0 ... tasks.length)
        {
            stepTasks[i] = tasks[i];
            tasksToRun.push(stepTasks[i]);

            blockingTasks[i] = new BlockingTask();
            tasksToRun.push(blockingTasks[i]);
        }

        super(tasksToRun);
    }

    public function unblockAllSteps(): Void
    {
        for (i in 0 ... blockingTasks.length)
        {
            blockingTasks[i].unblock();
        }
    }

    public function unblockStepAtIndex(index: Int): Void
    {
        if (index >= blockingTasks.length)
        {
            return;
        }

        blockingTasks[index].unblock();
    }

    public function unblockNextStep(): Void
    {
        if (currentStepIndex >= blockingTasks.length)
        {
            return;
        }

        blockingTasks[currentStepIndex].unblock();
        ++currentStepIndex;
    }
}
