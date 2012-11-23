package utils 
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	/**
	 * ...Data Base Controll Class
	 * @author Leonid Trofimchuk
	 */
	public class DataControll extends EventDispatcher
	{
		static public const DATA_COMPLETE:String = "dataComplete";
		
		private var sQLConnection:SQLConnection;					//Create DataBase and Control
		private var currentStatement:SQLStatement;					//Current SQL Statement
		private var dataBaseFile:File;								//Reference to Data Base File
		private var sqlText:String;									//SQL Text
		
		private var curXML:XML;
		private var getPhase:int;
		private var resultPackage:Array;
		
		private var result:Object = { };						//Current results
		
		private var vegetablesStatement:SQLStatement;
		private var scoresStatement:SQLStatement;
		private var curNameVegetable:String;
		
		public function DataControll() 
		{
			initFiles();
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods definition
//
//-------------------------------------------------------------------------------------------------
		
		private function initFiles():void 
		{
			//Application Direcrory
			var folder:File = File.applicationDirectory; 
			dataBaseFile = folder.resolvePath("data.db"); 
			
			Main.log("Existing db file: " + dataBaseFile.exists.toString());
			Main.log(dataBaseFile.nativePath.toString());
			
			if (!dataBaseFile.exists)
				initCreateSQL();
			else
				initUpdateSql();
		}
		
		//Create SQL Connection with SQLMode.CREATE
		private function initCreateSQL():void 
		{
			sQLConnection = new SQLConnection(); 	
			sQLConnection.addEventListener(SQLEvent.OPEN, sQLConnection_create); 
			sQLConnection.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
			sQLConnection.openAsync(dataBaseFile, SQLMode.CREATE); 
		}
		
		//Create SQL Connection with SQLMode.UPDATE	
		private function initUpdateSql():void
		{
			sQLConnection = new SQLConnection(); 	
			sQLConnection.addEventListener(SQLEvent.OPEN, sQLConnection_open); 
			sQLConnection.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
			sQLConnection.openAsync(dataBaseFile, SQLMode.UPDATE);
		}
		
		//Create Tables When It's Don't Exist 
		private function createTables():void 
		{
			vegetablesStatement = new SQLStatement();
			vegetablesStatement.sqlConnection = sQLConnection;
				
			//Vegetables Table	
			var vegetableText: String;
			vegetableText = "CREATE TABLE IF NOT EXISTS vegetables (" +  
							  "    vegId INTEGER PRIMARY KEY AUTOINCREMENT, " +  
							  "    name TEXT, " +  
							  "    x NUMERIC, " +  
							  "    y NUMERIC, " +  
							  "    phase NUMERIC " +  
							  ")"; 
								
			vegetablesStatement.text = vegetableText;
			vegetablesStatement.execute();
				
			vegetablesStatement.addEventListener(SQLEvent.RESULT, vegetablesStatement_onResult); 
			vegetablesStatement.addEventListener(SQLErrorEvent.ERROR, statement_error);
						
			scoresStatement = new SQLStatement();
			scoresStatement.sqlConnection = sQLConnection;
			
			//Score Table
			var scoreText: String;
			scoreText = "CREATE TABLE IF NOT EXISTS scores (" +  
						  "    clover NUMERIC, " +  
						  "    potato NUMERIC, " +  
						  "    sunflower NUMERIC " +   
						  ")"; 
							
			scoresStatement.text = scoreText;
			scoresStatement.execute();
				
			scoresStatement.addEventListener(SQLEvent.RESULT, scoresStatement_onResult); 
			scoresStatement.addEventListener(SQLErrorEvent.ERROR, statement_error);
			
			
		}
		
		//Write Scores
		private function writeScores():void 
		{
            sQLConnection.addEventListener(SQLEvent.BEGIN, writeScoresHandler);
            sQLConnection.begin();
		}
		
		private function resetVegetables():void
		{
			sQLConnection.addEventListener(SQLEvent.BEGIN, resetVegetablesHandler);
            sQLConnection.begin();
		}
		
		private function resetScores():void
		{
			sQLConnection.addEventListener(SQLEvent.BEGIN, resetScoresHandler);
            sQLConnection.begin();
		}
		
		//Update Scores
		private function updateScores(clover:int = 0, potato:int = 0, sunflower:int = 0):void
		{
			result["clover"] = clover;
			result["potato"] = potato;
			result["sunflower"] = sunflower;
			
			sQLConnection.addEventListener(SQLEvent.BEGIN, updateScoresHandler);
            sQLConnection.begin();
		}
		
		//Delete Vegetables From Table
		public function takeVegetable(curNameVegetable:String):void
		{
			this.curNameVegetable = curNameVegetable;
			sQLConnection.addEventListener(SQLEvent.BEGIN, commitTakeVegetable);
            sQLConnection.begin();
		}
		
		//Write Planted Vagetables
		public function writeVegetableToSQL(vegetable:XML):void 
		{
			curXML = vegetable;
            sQLConnection.addEventListener(SQLEvent.BEGIN, commitVegetable);
            sQLConnection.begin();
		}
		
		//Grouth Phase Increase
		public function makeStep(): void
		{
			sQLConnection.addEventListener(SQLEvent.BEGIN, phaseIncrease);
            sQLConnection.begin();
		}
		
		//Get Data
		public function getAllData():void
		{
			resultPackage = new Array();
			getPhase = 0;
			getVegetables();
			getScores();
		}
		
		//Reset Proggres
		public function resetData():void
		{
			resetScores();
			//resetVegetables();
		}
		
		
		//Get Vegetables from Table
		private function getVegetables():void 
		{
			vegetablesStatement = new SQLStatement();
			vegetablesStatement.sqlConnection = sQLConnection;
			vegetablesStatement.text = "SELECT vegId, name, x, y, phase FROM vegetables;";
            vegetablesStatement.addEventListener(SQLEvent.RESULT, resultHandler);
			vegetablesStatement.addEventListener(SQLErrorEvent.ERROR, statement_error);
			vegetablesStatement.execute();
		}
		
		//Get Scores from Table
		private function getScores():void 
		{
			scoresStatement = new SQLStatement();
			scoresStatement.sqlConnection = sQLConnection;
			scoresStatement.text = "SELECT clover, potato, sunflower FROM scores;";
            scoresStatement.addEventListener(SQLEvent.RESULT, resultHandler);
			scoresStatement.addEventListener(SQLErrorEvent.ERROR, statement_error);
			scoresStatement.execute();
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------	
		
		private function sQLConnection_create(e:SQLEvent):void 
		{
			createTables();
			Main.log("the database was created successfully");
		}
		
		private function sQLConnection_open(e:SQLEvent):void 
		{
			Main.log("the database was opened successfully");
		}
			
		private function sQLConnection_error(e:SQLErrorEvent):void 
		{
			Main.log(e.error.message);
		}
			
		private function vegetablesStatement_onResult(e:SQLEvent):void 
		{
			Main.log("vegetablesStatement: " + e.target.toString());			
		}		
		
		private function scoresStatement_onResult(e:SQLEvent):void 
		{
			Main.log("scoresStatement: " + e.target.toString());
			writeScores();
		}
			
		private function statement_error(e:SQLErrorEvent):void 
		{
			Main.log(e.error.message);
		}
		
		
//////////////////////////////
		//Statement Handlers//
//////////////////////////////
		
		//Write 0 Scores If scores No Exist
   		private function writeScoresHandler(e:SQLEvent):void
        {
            sQLConnection.removeEventListener(SQLEvent.BEGIN, writeScoresHandler);
            
            // create and execute the first SQL statement:
            // insert an employee record
            scoresStatement = new SQLStatement();
            scoresStatement.sqlConnection = sQLConnection;
            scoresStatement.text = 
                "INSERT INTO scores (clover, potato, sunflower) " + 
                "VALUES (:value, :value, :value)";
				            
			scoresStatement.parameters[":value"] = 0;
			
            scoresStatement.addEventListener(SQLEvent.RESULT, executeHandler);
            scoresStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            
            scoresStatement.execute();
			
        }
		
		
		//Reset Score
		private function resetScoresHandler(e:SQLEvent):void
        {
            sQLConnection.removeEventListener(SQLEvent.BEGIN, resetScoresHandler);
            
            // create and execute the first SQL statement:
            // insert an employee record
            scoresStatement = new SQLStatement();
            scoresStatement.sqlConnection = sQLConnection;
            scoresStatement.text = "UPDATE scores SET clover = :value, potato = :value, sunflower = :value";
				            
			scoresStatement.parameters[":value"] = 0;
			
            scoresStatement.addEventListener(SQLEvent.RESULT, executeScoresHandler);
            scoresStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            
            scoresStatement.execute();
			
        }
		
		private function executeScoresHandler(e:SQLEvent):void 
		{
			
			var statement:SQLStatement = e.target as SQLStatement;
            statement.removeEventListener(SQLEvent.RESULT, executeScoresHandler);
            statement.removeEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            
            // No errors so far, so commit the transaction
            sQLConnection.addEventListener(SQLEvent.COMMIT, commitScoresHandler);
            sQLConnection.commit();
        }
		
		// Called after the transaction is committed
        private function commitScoresHandler(e:SQLEvent):void
        {
            sQLConnection.removeEventListener(SQLEvent.COMMIT, commitScoresHandler);
            Main.log("Transaction complete " + e.target);
			resetVegetables();
        }
		
		//Remove all vegetables from table
        private function resetVegetablesHandler(e:SQLEvent):void
        {
            sQLConnection.removeEventListener(SQLEvent.BEGIN, resetVegetablesHandler);
            
            // create and execute the first SQL statement:
            // insert an employee record
            vegetablesStatement = new SQLStatement();
            vegetablesStatement.sqlConnection = sQLConnection;
            vegetablesStatement.text = 
                "DELETE FROM vegetables "; 
				            
            vegetablesStatement.addEventListener(SQLEvent.RESULT, executeHandler);
            vegetablesStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            
            vegetablesStatement.execute();
			
			
        }
		
		//Update Scores Handler
		private function updateScoresHandler(e:SQLEvent):void 
		{
			sQLConnection.removeEventListener(SQLEvent.BEGIN, updateScoresHandler);
			
			scoresStatement = new SQLStatement();
            scoresStatement.sqlConnection = sQLConnection;
           
			scoresStatement.text = 
                "UPDATE scores" + 
                "SET clover = :clover, potato = :potato, sunflower = :sunflower" +
				"WHERE id=1";
				            
			scoresStatement.parameters[":clover"] = result["clover"];
            scoresStatement.parameters[":potato"] = result["potato"];
            scoresStatement.parameters[":sunflower"] = result["sunflower"];
			
			scoresStatement.addEventListener(SQLEvent.RESULT, executeHandler);
            scoresStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            
            scoresStatement.execute();
		}
		
		// Called when the transaction to Write Planted Vagetables begins
        private function commitVegetable(event:SQLEvent):void
        {
            sQLConnection.removeEventListener(SQLEvent.BEGIN, commitVegetable);
            
            //Insert Vegetables In Table
            currentStatement = new SQLStatement();
            currentStatement.sqlConnection = sQLConnection;
            currentStatement.text = 
                "INSERT INTO vegetables (name, x, y, phase) " + 
                "VALUES (:name, :x, :y, :phase)";
				           
			currentStatement.parameters[":name"] = curXML.@name;
            currentStatement.parameters[":x"] = curXML.@x;
            currentStatement.parameters[":y"] = curXML.@y;
            currentStatement.parameters[":phase"] = curXML.@phase;
			
            currentStatement.addEventListener(SQLEvent.RESULT, executeHandler);
            currentStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            currentStatement.execute();
        }
		
		//Select Vegetables to Take Handler
		private function commitTakeVegetable(e:SQLEvent):void
        {
            sQLConnection.removeEventListener(SQLEvent.BEGIN, commitTakeVegetable);
            vegetablesStatement = new SQLStatement();
            vegetablesStatement.sqlConnection = sQLConnection;
			
			vegetablesStatement.text = "SELECT vegId, name, x, y, phase FROM vegetables WHERE name = :name AND " 
			+ "phase = :phase";
				
            vegetablesStatement.parameters[":name"] = this.curNameVegetable;			
            vegetablesStatement.parameters[":phase"] = 5;			
			
            vegetablesStatement.addEventListener(SQLEvent.RESULT, takeSelectVegetablesHandler);
            vegetablesStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            
            vegetablesStatement.execute();		
		}
		
		//Remove Selected Vegetables Handler
		private function takeSelectVegetablesHandler(e:SQLEvent):void 
		{
			vegetablesStatement.removeEventListener(SQLEvent.RESULT, takeSelectVegetablesHandler);
			vegetablesStatement.removeEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
			var result:SQLResult = (e.target as SQLStatement).getResult();
			if (result != null)
			{	
				var inc:int = result.data.length;
				if (inc > 0 ) 
				{
					vegetablesStatement = new SQLStatement();
					vegetablesStatement.sqlConnection = sQLConnection;
					vegetablesStatement.text = "DELETE FROM vegetables " + 
					"WHERE name = :name AND " +
					"phase = :phase";
					
					vegetablesStatement.parameters[":name"] = this.curNameVegetable;			
					vegetablesStatement.parameters[":phase"] = 5;
					vegetablesStatement.addEventListener(SQLEvent.RESULT, executeHandler);
					vegetablesStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);            
					vegetablesStatement.execute();
					
					scoresStatement = new SQLStatement();
					scoresStatement.sqlConnection = sQLConnection;
					scoresStatement.text = "UPDATE scores SET" + 
					this.curNameVegetable + "= value + 1";
					scoresStatement.addEventListener(SQLEvent.RESULT, executeHandler);
					scoresStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);            
					scoresStatement.execute();
				}
			}
		}
		
		//Phase Increase Handler
		private function phaseIncrease(e:SQLEvent):void 
		{
			sQLConnection.removeEventListener(SQLEvent.BEGIN, phaseIncrease);
			
			vegetablesStatement = new SQLStatement();
            vegetablesStatement.sqlConnection = sQLConnection;
			
			vegetablesStatement.text = "SELECT name, x, y, phase FROM vegetables WHERE phase < 5"; 
			
			vegetablesStatement.addEventListener(SQLEvent.RESULT, phaseIncreaseSelectHandler);
            vegetablesStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            
            vegetablesStatement.execute();	
		}
		
		//Phase Increase in SELECT Handler
		private function phaseIncreaseSelectHandler(e:SQLEvent):void 
		{
			vegetablesStatement.removeEventListener(SQLEvent.RESULT, takeSelectVegetablesHandler);
			vegetablesStatement.removeEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
			
			var result:SQLResult = (e.target as SQLStatement).getResult();
			if (result != null)
			{
				var inc:int = result.data.length;
				if (inc > 0 ) 
				{
					vegetablesStatement = new SQLStatement();
					vegetablesStatement.sqlConnection = sQLConnection;
					vegetablesStatement.text = "UPDATE vegetables SET" + 
					"phase = phase + 1";
					
					vegetablesStatement.addEventListener(SQLEvent.RESULT, executeHandler);
					vegetablesStatement.addEventListener(SQLErrorEvent.ERROR, sQLConnection_error);            
					vegetablesStatement.execute();
				}
			}
		}
			
		//Compile Result from Base
		private function resultHandler(e:SQLEvent):void 
		{			
			var result:SQLResult = (e.target as SQLStatement).getResult();
			if (result != null)
			{
				getPhase++;
				if (result.data == null)
					return;
				resultPackage = resultPackage.concat(result.data);
				for (var i:int = 0; i < result.data.length; i++) 
				{
					var row:Object = result.data[i];
					if (row.hasOwnProperty("name"))
					{
						Main.log(i + ". name:" + row.name + ", x:" + row.x + ", y:" + row.y + ", phase:" +row.phase);
					}
					if (row.hasOwnProperty("clover")) {
						Main.log(i + ". clover:" + row.clover + ", potato:" + row.potato + ", sunflower:" + row.sunflower);
					}
				}			
				if (getPhase == 2) 
				{
					this.dispatchEvent(new Event(DataControll.DATA_COMPLETE));
				}
			}
		}
		
		// Called after the  record is inserted
        private function executeHandler(e:SQLEvent):void
        {
			var statement:SQLStatement = e.target as SQLStatement;
            statement.removeEventListener(SQLEvent.RESULT, executeHandler);
            statement.removeEventListener(SQLErrorEvent.ERROR, sQLConnection_error);
            
            // No errors so far, so commit the transaction
            sQLConnection.addEventListener(SQLEvent.COMMIT, commitHandler);
            sQLConnection.commit();
        }
		
		// Called after the transaction is committed
        private function commitHandler(e:SQLEvent):void
        {
            sQLConnection.removeEventListener(SQLEvent.COMMIT, commitHandler);
            Main.log("Transaction complete " + e.target);
        }
		
//--------------------------------------------------------------------------
//
//  Getters and Setters
//
//--------------------------------------------------------------------------
		
		public function get allPackage():Array 
		{
			return resultPackage;
		}
		
	}

}