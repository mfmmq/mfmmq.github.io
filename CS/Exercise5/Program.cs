using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Exercise
{
	class MainClass
	{

		public static void Main (string[] args)
		{
			
			Del1 MyOperation = new Del1 (Times2);

			// Create IENumberable style type
			int[] myArrayOfInts = {10, 20, 30, 40};
			ForEach (myArrayOfInts, MyOperation);
			IEnumerable<int> myArrayofInts2 =  Map (myArrayOfInts, MyOperation);
			Console.Write ("My new array of ints is ");
			foreach (int i in myArrayofInts2) {
				Console.Write ("{0} ", i);
			}
			Console.Write ("\n");
			DelT<int> Predicate = MyPredicate;

			int[] Instance1 = { 1, 2, 3, 4, 5 };
			int[] Instance2 = { 1, -3, -10, 6, -100 };

			IEnumerable<int> Instance3 = Partition<int> (Instance1, Instance2, Predicate);
			foreach(int i in Instance3) {Console.Write ("{0}", i);}
			Console.WriteLine ("");

			MagicGeneric<string,string>.Delkvp MyAllCaps = new MagicGeneric<string,string>.Delkvp (MagicGeneric<string,string>.PrintUpper);

			MagicGeneric<string,string> MyGeneric = new MagicGeneric<string,string> ();
			MyGeneric.Add ("Word1", "This is the definition of the first entry.");
			MyGeneric.Add ("Word2", "This is the definition of the second entry.");
			MyGeneric.Add ("Word3", "This is the definition of the third entry.");
			MyGeneric.Add ("Word4", "This is the definition of the fourth entry.");
			MyGeneric.Add ("Word5", "This is the definition of the fifth entry.");
			MyGeneric.DelegateAll (MyAllCaps);
			MyGeneric.PrintAll ();


			MagicDictionary MyDictionary = new MagicDictionary ();
			MyDictionary.Add ("Word1", "This is the definition of the first entry.");
			MyDictionary.Add ("Word2", "This is the definition of the second entry.");
			MyDictionary.Add ("Word3", "This is the definition of the third entry.");
			MyDictionary.Add ("Word4", "This is the definition of the fourth entry.");
			MyDictionary.Add ("Word5", "This is the definition of the fifth entry.");
			MyDictionary.Add ("LongestWord", "This is the definition of the fifth entry.");



		}


	


		public class MagicGeneric<T,V>
		{
			public event EventHandler<MagicEventArgs> NewEvent;
			private IDictionary<T, V> dict = new Dictionary<T, V> ();


			// methods in magicdictionary
			public void Add (T word, V definition)
			{
				dict.Add (word, definition);
				dict.NewEvent += NewEventHandler;
				OnNewEvent (new MagicEventArgs ());
			}

			public void Remove (T word)
			{
				if (!(dict.ContainsKey (word))) {
					// Exception
				}
				dict.Remove (word);
			}

			public void Set (T word, V definition)
			{
				if (!(dict.ContainsKey (word))) {
					dict.Add (word, definition);
				} else {
					dict.Remove (word);
					dict.Add (word, definition);
				}

			}

			public V Get (T word)
			{
				return dict [word];
			}

			public void PrintAll ()
			{
				foreach (KeyValuePair <T , V > kvp in dict) {
					Console.WriteLine ("{0}\t\t {1}", kvp.Key, kvp.Value);
				}
			}
			// print everything to the console

			public void DelegateAll(Delkvp MyAction) {
				foreach (KeyValuePair<T,V> kvp in dict) {
					MyAction (kvp);
				}

			}

			public delegate void Delkvp (KeyValuePair<T,V> kvp); 
			public static void PrintUpper(KeyValuePair<string,string> kvp) 
			{
				Console.WriteLine("{0}\t\t {1}",kvp.Key,kvp.Value.ToUpper());
			}


			// protected virtual method to raise event
			protected virtual void OnNewEvent (MagicEventArgs e) {
				EventHandler<MagicEventArgs> handler = NewEvent;
				if (handler != null)
					handler (this, e);
			}


			static void NewEventHandler (object sender, MagicEventHandler e ){}

			public class MagicEventArgs : EventArgs
			{
			}
		}
















		public class MagicDictionary
		{

			private IDictionary<string, string> dict = new Dictionary<string, string> ();


			// methods in magicdictionary
			public void Add (string word, string definition)
			{
				dict.Add (word, definition);
			}

			public void Remove (string word)
			{
				if (!(dict.ContainsKey (word))) {
					// Exception
				}
				dict.Remove (word);
			}

			public void Set (string word, string definition)
			{
				if (!(dict.ContainsKey (word))) {
					dict.Add (word, definition);
				} else {
					dict.Remove (word);
					dict.Add (word, definition);
				}

			}

			public string Get (string word)
			{
				return dict [word];
			}

			public void PrintAll ()
			{
				foreach (KeyValuePair <string , string > kvp in dict) {
					Console.WriteLine ("{0}\t\t {1}", kvp.Key, kvp.Value);
				}
			}

		}





		public static  IEnumerable<T> Partition<T>(IEnumerable<T> Instance1, IEnumerable<T> Instance2, DelT<T> d)
		{
			// split two IEnumerable instances based on a supplied predicate
			// combine both instances
			Instance1 = Instance1.Concat(Instance2);
			// yield return everything that matches the predicate
			foreach (T t in Instance1)
			{
				if (d.Invoke(t)) {
					yield return (T) t;
				}
			}
		}

		public delegate bool DelT<T> (T t);

		public static bool MyPredicate(int t) {
			if (t > 0 ) {
					return true;
			} else {
				return false;
			}
		}

//		Provide an extension method for all IEnumerable<T> called Partition which allows a collection to be
//			split into two IEnumerable<T> instances based on a supplied predicate.
//			Test your partition method using both lambda expressions and .NET 2.0 anonymous method
//				expressions.
//


		// Testing blocks
		public static void ClassTest ()
		{
			Console.WriteLine ("Hello World!");
			
			// set information about student to test if it is working
			Student Jabus = new Student ();
			Jabus.Name = "Jabus";
			Jabus.Subject = "Biology";
			Jabus.School = "Deerfield";
			
			// create an array of students and print out each of their details
			Student[] Classroom = new Student[4];
			Classroom [0] = Jabus;
			Classroom [1] = new Student ("Mabus", "Biology", "Deerfield");
			Classroom [2] = new Student ("Titus", "Chemistry", "Deerfield");
			Classroom [3] = new Student ("Brutus", "Math", "Corpus Deerfield");
			
			foreach (Student s in Classroom) {
				s.PrintInfo ();
			}
			
			// test the transcript
			Jabus.NewGrade ("Biology", 72);
			Jabus.NewGrade ("Math", 83);
			Jabus.NewGrade ("Chemistry", 75);
			//Console.WriteLine ("{0}", Jabus.Grades ["English"]);
			
			Console.WriteLine ("Jabus's rating... {0}", Jabus.Rating ());
			Console.WriteLine ("");
		}

		public static void DictionaryTest ()
		{
			MagicGeneric<string,string> MyDictionary = new MagicGeneric<string,string> ();
			MyDictionary.Add ("Word1", "This is the definition of the first entry.");
			MyDictionary.Add ("Word2", "This is the definition of the second entry.");
			MyDictionary.Add ("Word3", "This is the definition of the third entry.");
			MyDictionary.Add ("Word4", "This is the definition of the fourth entry.");
			MyDictionary.Add ("Word5", "This is the definition of the fifth entry.");



		}

		public static void TimerTest ()
		{
			Del HelloDel = new Del (HelloWorld);
			using (Timer t = new Timer (HelloDel)) {

				Cartesian Point1 = new Cartesian (3, 5);
				Cartesian Point2 = new Cartesian (-2, 3);

				Point1.PrintCartesian ();
				Point2.PrintCartesian ();
				Point1.MoveAbsolute (Point2);
				Point1.PrintCartesian ();

				if (Point1 == Point2) {
					Console.WriteLine ("Points are equal");
				}

				Console.WriteLine (Point1.ToString ());
			}
		}


		class Timer : IDisposable
		{
			private DateTime start;
			private TimeSpan ts;

			public Timer (Del MyAction) // get start time datetime
			{
				//message = Message; // what does this mean? 
				start = DateTime.Now;
				Dispose ();
				MyAction() ;
			}

			// implement disposable interface
			public void Dispose ()
			{
				DateTime end = DateTime.Now;
				ts = end - start;
				Console.WriteLine ("{0}", ts);
				MainClass.HelloWorld ();
			}

		}


		public delegate void Del ();
		public delegate float Del1(float i);

		public static void HelloWorld ()
		{
			Console.WriteLine ("Hello world!");
		}

		public static float Times2 (float i) {
			return i*2;
		}


		public static void ForEach (IEnumerable<int> InputVariable, Del1 d)
		{
			foreach (int i in InputVariable) {
				Console.Write ("{0} becomes ", i);
				Console.Write ("{0} \n", d (i));
			}
		}

		public static IEnumerable<int> Map (IEnumerable<int> InputVariable, Del1 d) {
			for (int i = 0; i < InputVariable.Count(); i++) {
				yield return  (int) d (InputVariable.ElementAt (i));
			}
		}


	}


	 
	interface IHasPosition { Cartesian CurrentPosition { get; set; } }


	abstract class Person : IHasPosition
	{
		public Person () {}
		public Person (string Name) {}
		protected string name;
		public string Name { get { return name; } set { name = value; } }
		public abstract float Rating ();
		public Cartesian CurrentPosition { 
			get;
			set;
		}

	}



	class Student:Person
	{
		public Student () {}
		public Student (string Name, string Subject, string School)
		{
			name = Name;
			subject = Subject;
			school = School;
		}
		private string subject;
		private string school;

		public void PrintInfo () {System.Console.WriteLine ("Name: {0}  ,  Subject: {1}  ,  School: {2}", name, subject, school);}

		public string Subject { get { return subject; } set { subject = value; } }
		public string School { get { return school; } set { school = value; } }
		private IDictionary<string, float> dict = new Dictionary<string, float> ();
		public void NewGrade (string subjectname, float subjectmark)
		{
			dict.Add (subjectname, subjectmark);
		}

		public float Grade (string subjectname)
		{
			return dict [subjectname];
		}

		public override float Rating ()
		{
			float totalgrade = 0;
			int c = 0;
			foreach (KeyValuePair<string, float> item in dict) {
				c++;
				totalgrade = totalgrade + item.Value;
			}
			return totalgrade / c;
		}
			
	}


	class Instructor : Person
	{
		
		//private string subject;
		public override float Rating ()//(Person[] ListofPeople)
		{
			//foreach (Person p in ListofPeople) {
			//}
			return 0;
		}

	}






	struct Cartesian
	{

		// All necessary constructors
		//public Cartesian();
		public Cartesian (float _x, float _y)
		{
			x = _x;
			y = _y;
		}

		private float x;
		private float y;

		// Methods to move the position held in the co-ordinate both relatively and absolutely
		public float X { get { return x; } set { x = value; } }

		public float Y { get { return y; } set { y = value; } }

		public void MoveAbsolute (float _x, float _y)
		{
			x = _x;
			y = _y;
		}

		public void MoveRelative (float _xd, float _yd)
		{
			x = x + _xd;
			y = y + _yd;
		}

		public void MoveAbsolute (Cartesian _point)
		{
			x = _point.X;
			y = _point.Y;
		}

		public void PrintCartesian ()
		{
			Console.WriteLine ("({0},{1})", x, y);
		}

		// appropriate overrides for ToString, Equals and GetHashCode

		// Override Equals, GetHashCode
		public override bool Equals (Object coord)
		{
			if (coord == null)
				return false; // step 1
			if (this.GetType () != coord.GetType ())
				return false; // step 2
			return true; // step 4ii
		}

		public static bool operator == (Cartesian lhs, Cartesian rhs)
		{
			return lhs.Equals (rhs);
		}

		public static bool operator != (Cartesian lhs, Cartesian rhs)
		{
			return !lhs.Equals (rhs);
		}

		public override int GetHashCode ()
		{
			return base.GetHashCode ();
		}


		// Override + , -
		public static Cartesian operator+ (Cartesian Point1, Cartesian Point2)
		{
			return new Cartesian (Point1.X + Point2.X, Point1.Y + Point2.Y);
		}

		// Override GetHashCode


		// Override ToString
		public override string ToString ()
		{
			return "(" + Convert.ToString (x) + "," + Convert.ToString (y) + ")";
		}


	}






	// value type to represent the separation/distance between two coordinates
	struct Distance
	{
		private float distance;

		public Distance (Cartesian Point1, Cartesian Point2)
		{
			distance = ((Point1.X - Point2.X) * (Point1.X - Point2.X) + (Point1.Y - Point2.Y) * (Point1.Y - Point2.Y));
			distance = (float)Math.Sqrt (distance);
		}

	}
























}


