using System;
using System.Collections;

namespace Exercise
{
	class MainClass
	{





		public static void Main (string[] args)
		{
			Console.WriteLine ("Hello World!");

			// set information about student to test if it is working
			Student Jabus = new Student();
			Jabus.Name = "Jabus";
			Jabus.Subject = "History";
			Jabus.School = "Deerfield";

			// create an array of students and print out each of their details
			Student[] Classroom = new Student[4];
			Classroom [0] = Jabus;
			Classroom [1] = new Student("Mabus","Biology","Exeter");
			Classroom [2] = new Student("Titus","Chemistry","Jesus");
			Classroom [3] = new Student("Brutus","English","Corpus Cristi");

			foreach (Student s in Classroom) {
				s.PrintInfo ();
			}

			// test the transcript
			Jabus.Transcript["Biology"] = 72;


			Cartesian Point1 = new Cartesian (3, 5);
			Cartesian Point2 = new Cartesian (-2, 3);

			Point1.PrintCartesian ();
			Point2.PrintCartesian ();
			Point1.MoveAbsolute (Point2);
			Point1.PrintCartesian ();

			if (Point1 == Point2) {
				Console.WriteLine ("Points are equal");
			} else {

			}

			Console.WriteLine(Point1.ToString ());
		}
	}






	class Person 
	{
		public Person() {}
		public Person(string Name) {}

		protected string name;

		public string Name { get{ return name;} set{ name = value;} }
	}





	class Student:Person
	{
		public Student(){}
		public Student(string Name, string Subject, string School) {name = Name; subject = Subject; school = School;}
		//public Student(string Name, string Subject, string School, float mark) {}

		private string subject;
		private string school;
		//private float mark = 0;


		public void PrintInfo()
		{
			System.Console.WriteLine ("Name: {0}  ,  Subject: {1}  ,  School: {2}", name, subject, school);
		}

		class Grades 
		{
			SortedList GradeList = new SortedList();
			public float this[string subjectname]
			{
				get { return (float)GradeList [subjectname]; }
				set { GradeList [subjectname] = value; }
			}
		}
				
	}















	struct Cartesian {

		// All necessary constructors
		//public Cartesian();
		public Cartesian(float _x, float _y){x = _x; y= _y;}

		private float x;
		private float y;

		// Methods to move the position held in the co-ordinate both relatively and absolutely
		public float X {get {return x;} set {x = value;}}
		public float Y {get {return y;} set {y = value;}}
		public void MoveAbsolute(float _x , float _y) { x = _x; y = _y;}
		public void MoveRelative(float _xd , float _yd) {x = x+_xd; y = y+_yd;}
		public void MoveAbsolute(Cartesian _point) {x = _point.X; y = _point.Y;}
		public void PrintCartesian() {Console.WriteLine("({0},{1})",x,y);}

		// appropriate overrides for ToString, Equals and GetHashCode

		// Override Equals
		public override bool Equals(Object coord) {
			if (coord == null) return false; // step 1
			if (this.GetType() != coord.GetType()) return false; // step 2
			return true; // step 4ii
		}
		public static bool operator ==(Cartesian lhs, Cartesian rhs) {
			return lhs.Equals(rhs);
		}
		public static bool operator !=(Cartesian lhs, Cartesian rhs) {
			return !lhs.Equals(rhs);
		}


		// Override + , - 
		public static Cartesian operator+ (Cartesian Point1, Cartesian Point2) 
		{

		}

		// Override GetHashCode


		// Override ToString
		public override string ToString () { return "(" + Convert.ToString (x) +"," + Convert.ToString(y)+")";}


	}











	// value type to represent the separation/distance between two coordinates
	struct Distance 
	{
		public Distance(Cartesian Point1, Cartesian Point2) 
		{

		}
	}







	// using value type, interface which can be implemented by anything which has a position
	// member which returns current position of implementing object w co-ordinate value type
	interface IHasPosition
	{
		Cartesian CurrentPosition();
	}

	struct Student : IHasPosition
	{
		pri
		public Cartesian CurrentPosition() {return Cartesian(x,y)}
	}







}





//	Create a second value type which can be used to represent the separation/distance between two coordinates.
//	You will use this type later to support several operations of your co-ordinate value type. You
//	may find the DateTime and Timespan value types useful examples here.
//	2. Using the value type
//	Define an interface, IHasPosition which can be implemented by anything which has a position. It
//	should define at least one member which returns the current position of the implementing object. Make
//	use of your co-ordinate value type.
//	Both Student and Instructor are capable of having a position. Ensure that they implement
//	the IHasPosition interface. Consider (and test):
//	o the implications of having Person implement the IHasPosition interface (versus having Instructor and
//		Student implement the interface themselves).
//	o the implications of implementing the interface explicitly or implicitly.
//	3. Overloading operators
//	Consider which operators can sensibly be overloaded for your co-ordinate type. You should overload at
//	least:
//	o The == and != operators.
//	o The binary + and - operators (using your distance type defined in question 1)
//	You should think carefully about the semantics of your operations. For example, does it really make
//	sense to add two point objects?
//	4. Extension Methods
//	Add missing capabilities to the FCL types that you wish were already there. Try to be imaginative, but
//	for the less imaginative consider (NB some of these suggestions require familiarity with features covered
//		later in the course - feel free to be selective or read ahead!):
//	o IsPalindrome on String
//	o IsPrime on int
//	o Reverse on StringBuilder
//	o Describe on Object - using reflection to pretty-print the entire object details to a provided
//	stream/writer.
//	o SampleEveryNth on IEnumerable (use yield return and iterators)