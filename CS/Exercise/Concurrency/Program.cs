using System;
using System.Threading;


namespace Concurrency
{
	class MainClass
	{
		public static void Main (string[] args)
		{
			Random rnd = new Random();
			int time = rnd.Next (1000, 3000);
			Thread[] threadArray = new Thread[5];


			for (int i = 0; i < 5; i++)
			{
				threadArray [i] = new Thread (new ParameterizedThreadStart (RandomSleep));
				threadArray[i].Start (time);

			}
			for (int i = 0; i < 5; i++) {
			}

			// Create delegate

		}

		//public delegate void ThreadStart();

		static void RandomSleep (object time)
		{
			//time = rnd.Next (1000, 3000);
			Thread.Sleep((int) time);
			double disptime = (float) (int) time / 1000;
			Console.WriteLine ("Slept for {0} seconds...", disptime);
		}




	}



}


//							2. Using delegates and the asynchronous programming model
//							Using the same sleep method from the previous solution (the one which takes a sleep time parameter),
//							write a test harness that will call this method via a delegate. Initially call the delegate five times
//							sequentially passing in the sleep time (a random value between 1 and 5 seconds).
//							Refactor your code so that the method now returns the sleep time rather than print out the value. Still
//							call the method sequentially.
//							Refactor your code so that you use asynchronous delegate calls and print out the sleep time from within
//							the callback method. Remember to keep your main thread alive using Console.ReadLine().
//							Refactor your code so that the sleep method returns void and takes a second out parameter to write
//							the sleep time to. Update your async delegate call and callback methods to pick up the sleep time via
//							the out parameter.
//							Finally combine both parameters into a single ref parameter which passes in the sleep time and is
//							updated with the actual time the sleep took (use a DateTime object to time how long the sleep method
//								takes to complete).
