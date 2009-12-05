// export CLASSPATH=".:./jFuzzyLogic_2.0.6.jar"
// javac ExpectedData.java 
// java ExpectedData > data.java

/*
 * adapted from original jFuzzyLogic's net/sourceforge/jFuzzyLogic/test/TestTipper.java 
 * written by: pcingola@users.sourceforge.net 
 */

import net.sourceforge.jFuzzyLogic.FIS;

public class ExpectedData {

	public static void main(String args[]) throws Exception {
		// Create FCL system
		String fcl = "FUNCTION_BLOCK tipper\n" + //
		"\n" + //
		"VAR_INPUT\n" + //
		"   service : REAL;\n" + //
		"   food : REAL;\n" + //
		"END_VAR\n" + //
		"\n" + //
		"VAR_OUTPUT\n" + //
		"   tip : REAL;\n" + //
		"END_VAR\n" + //
		"\n" + //
		"FUZZIFY service\n" + //
		"   TERM poor := (0, 1) (4, 0) ; \n" + //
		"   TERM good := (1, 0) (4,1) (6,1) (9,0);\n" + //
		"   TERM excellent := (6, 0) (9, 1) (10,1);\n" + //
		"END_FUZZIFY\n" + //
		"\n" + //
		"FUZZIFY food\n" + //
		"   TERM rancid := (0, 1) (1, 1) (3,0) ;\n" + //
		"   TERM delicious := (7,0) (9,1) (10,1);\n" + //
		"END_FUZZIFY\n" + //
		"\n" + //
		"DEFUZZIFY tip\n" + //
		"   TERM cheap := (0,0) (5,1) (10,0);\n" + //
		"   TERM average := (10,0) (15,1) (20,0);\n" + //
		"   TERM generous := (20,0) (25,1) (30,0);\n" + //
		"   METHOD : COG;\n" + //
		"   DEFAULT := 0;\n" + //
		"END_DEFUZZIFY\n" + //
		"\n" + //
		"RULEBLOCK No1\n" + //
		"   ACCU : MAX;\n" + //
		"   AND : MIN;\n" + //
		"   ACT : MIN;\n" + //
		"\n" + //
		"   RULE 1 : IF service IS poor OR food is rancid THEN tip IS cheap;\n" + //
		"   RULE 2 : IF service IS good THEN tip IS average; \n" + //
		"   RULE 3 : IF service IS excellent AND food IS delicious THEN tip is generous;\n" + //
		"END_RULEBLOCK\n" + //
		"\n" + //
		"END_FUNCTION_BLOCK\n";

		FIS fis = FIS.createFromString(fcl, true);

	    // Set different values for 'food' and 'service'. Evaluate the system and show variables
		for( double service = 0.0; service <= 10; service += 0.2 ) {
	      for( double food = 1; food <= 10; food += 0.2 ) {

  		    // Evaluate system using these parameters
			fis.getVariable("service").setValue(service);
			fis.getVariable("food").setValue(food);
			fis.evaluate();

			// Print result
			System.out.println(String.format("          %2.2f,", fis.getVariable("tip").getValue()));
          }
		}

	}
}
