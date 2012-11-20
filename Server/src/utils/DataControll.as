package utils 
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLStatement;
	import flash.display.Sprite;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	/**
	 * ...Data Base Controll Class
	 * @author Leonid Trofimchuk
	 */
	public class DataControll extends Sprite 
	{
		private var sQLConnection:SQLConnection;				//Create DataBase and Control
		private var currentStatement:SQLStatement;				//Current SQL Statement
		private var appFolder:File;								//Reference to App Folder
		private var dataBaseFile:File;							//Reference to Data Base File
		private var sqlText:String;								//SQL Text
		
		public function DataControll() 
		{
			initFiles();
			initSQL();
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods definition
//
//-------------------------------------------------------------------------------------------------
		
		private function initFiles():void 
		{
			// The database file is in the application storage directory 
			appFolder = File.applicationStorageDirectory; 
			dataBaseFile = appFolder.resolvePath("DataBase.db");
		}
		
		private function initSQL():void 
		{
			sQLConnection = new SQLConnection(); 	
			sQLConnection.addEventListener(SQLEvent.OPEN, sQLConnection_open); 
			sQLConnection.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
			sQLConnection.openAsync(dataBaseFile, SQLMode.UPDATE); 
		}
		
		private function initStatement():void 
		{
			currentStatement = new SQLStatement();
			currentStatement.sqlConnection = sQLConnection;
				
			//Table
			sqlText = "CREATE TABLE IF NOT EXISTS employees (" +  
					  "    empId INTEGER PRIMARY KEY AUTOINCREMENT, " +  
					  "    firstName TEXT, " +  
                      "    lastName TEXT, " +  
                      "    salary NUMERIC CHECK (salary > 0)" +  
                      ")"; 
						
			currentStatement.text = sqlText;
			currentStatement.execute();
			currentStatement.parameters[":firstName"] = "ItemFirst"; 
			currentStatement.parameters[":lastName"] = "ITemSec"; 
				
			currentStatement.addEventListener(SQLEvent.RESULT, currentStatement_result); 
			currentStatement.addEventListener(SQLErrorEvent.ERROR, currentStatement_error);	
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------	
		
		private function sQLConnection_open(e:SQLEvent):void 
		{
			initStatement();
			trace("the database was created successfully");
		}
			
		private function sQLConnection_error(e:SQLErrorEvent):void 
		{
			trace(e.error.message); 
		}
			
		private function currentStatement_result(e:SQLEvent):void 
		{
			trace(e.target);
		}
			
		private function currentStatement_error(e:SQLErrorEvent):void 
		{
			trace(e.error.message);
		}
		
	}

}