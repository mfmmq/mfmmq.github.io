using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace MagicDictionary
{
	class MainClass
	{
		public static void Main (string[] args)
		{
			Console.WriteLine ("Hello World!");

			// add some words to the dictionary
			MagicGeneric<string,string> MyDictionary = new MagicGeneric<string,string>();
			MyDictionary.Add("Hello","This is my definitionThis is my definition");
			MyDictionary.Add("Testing","This is my definitionajsdflkas jdlksa jdlkas jflksa ");
			MyDictionary.Add("Word1","This sdfkjsd lksa jflsakj is my definition");
			MyDictionary.Add("Word2","This is my das dlkajs dlka efinition");
			MyDictionary.Add("Word3","This is my definition");
			MyDictionary.Add("Word4","This is my definition");
			MyDictionary.Add("Word5","This is my definition");

			MyDictionary.PrintAll ();

			MyDictionary.Set ("Word2", "This is my new definition");
			MyDictionary.Remove ("Word3");
			Console.WriteLine ("The defintion of Hello is {0}", MyDictionary.Get ("Hello"));

			MyDictionary.PrintAll ();
		}
	}




	class MagicDictionary {

		private IDictionary<string, string> dict = new Dictionary<string, string> ();
		public 

		// methods in magicdictionary
		void Add(string word, string definition) {
			dict.Add(word, definition);
		}
		public void Remove(string word) {
			if (!(dict.ContainsKey(word))) {
				// Exception
			}
			dict.Remove (word);
		} 
		public void Set(string word, string definition) {
			if (!(dict.ContainsKey(word))) {
				dict.Add (word, definition);
			} else {
				dict.Remove (word);
				dict.Add (word, definition);
			}

		}
		public string Get(string word) {
			return dict [word];
		}
		public void PrintAll() {
			foreach (KeyValuePair <string , string > kvp in dict) {
				Console.WriteLine ("{0}\t\t {1}", kvp.Key, kvp.Value);
			}
		} // print everything to the console

 	}




	public class MagicGeneric<T,V> {

		private IDictionary<T, V> dict = new Dictionary<T, V> ();
		public 

		// methods in magicdictionary
		void Add(T word, V definition) {
			dict.Add(word, definition);
		}
		public void Remove(T word) {
			if (!(dict.ContainsKey(word))) {
				// Exception
			}
			dict.Remove (word);
		} 
		public void Set(T word, V definition) {
			if (!(dict.ContainsKey(word))) {
				dict.Add (word, definition);
			} else {
				dict.Remove (word);
				dict.Add (word, definition);
			}

		}
		public V Get(T word) {
			return dict [word];
		}
		public void PrintAll() {
			foreach (KeyValuePair <T , V > kvp in dict) {
				Console.WriteLine ("{0}\t\t {1}", kvp.Key, kvp.Value);
			}
		} // print everything to the console

	}


}
//
//
//Set(string key, string value) updates or adds
//o Get(string key) returns the value associated with key
//o PrintAll() - prints all of the values to the console
//o A method that works like TryGetValue (you'll need to use the help that's either installed with Visual
//	Studio or available through the MSDN web site)
//Clearly, you should be writing a wrapper that uses one of .Net's collections. Efficiency isn't the main
//concern while practising these concepts. For the purpose of this exercise, there is no requirement to
//	implement IDictionary.
//	7. Write test code to exercise your magic dictionary.
//	8. The Get method isn't really the correct way of doing things in .NET. Provide an indexer instead.
//	9. Provide your own type of exception that will be thrown instead of the underlying collection's exception.
//	10. Now make your MagicDictionary class a generic class, with the value being a generic type. Make sure
//	that only reference types (not structs) can be used for the value.
