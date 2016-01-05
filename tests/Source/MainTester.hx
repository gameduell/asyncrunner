import unittest.implementations.TestHTTPLogger;
import unittest.implementations.TestJUnitLogger;
import unittest.implementations.TestSimpleLogger;

import unittest.TestRunner;

import duellkit.DuellKit;

class MainTester
{
    static function main()
    {
        DuellKit.initialize(start);
    }

    static function start() : Void
    {
        var r = new TestRunner(testComplete, DuellKit.instance().onError);
        r.add(new TaskTest());
        r.add(new DelayTest());
        r.add(new ComplexTest());
        r.add(new ParallelTest());
        r.add(new SequentialTest());

        //HTTPLogger are supported on devices with android versions >= 5.0
        #if jenkins
            r.addLogger(new TestHTTPLogger(new TestJUnitLogger()));
        #else
            r.addLogger(new TestHTTPLogger(new TestSimpleLogger()));
        #end

        //If you want to run the tests on devices with android version < 5.0, uncomment the following line
        //r.addLogger(new TestSimpleLogger());

        r.run();
    }

    static function testComplete()
    {

    }

}
