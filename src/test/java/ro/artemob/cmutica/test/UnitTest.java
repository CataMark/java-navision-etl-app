package ro.any.catalin.test;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.DisplayName;
import ro.any.catalin.etl.DbConn;
import ro.any.catalin.etl.EtlQueries;
import ro.any.catalin.etl.Mail;
import ro.any.catalin.etl.StartUp;

/**
 *
 * @author catalin
 */
public class UnitTest {
    
    public UnitTest() {
    }
    
    @BeforeAll    
    public static void TestConfigDirectorySetup() throws Exception{
        StartUp.init();
    }
    
    @Test
    @DisplayName(value = "Check envar APPS_KEY")
    public void TestEnVar(){
        var _rezultat = System.getenv("APPS_KEY");
        assertNotNull(_rezultat, "envar exists");
    }
    
    @Test
    @DisplayName(value = "Initialization steps")
    public void TestConfigFiles(){
        var _confDirPath = Paths.get(StartUp.CONF_DIR);
        assertTrue(Files.exists(_confDirPath), "config directory exists");
        
        var _logDirPath = Paths.get(StartUp.CONF_DIR + StartUp.LOG_DIR_NAME);
        assertTrue(Files.exists(_logDirPath), "log directory exists");
        
        var _confFilePath = Paths.get(StartUp.CONF_DIR + File.separator + StartUp.CONF_PROPS_FILE_NAME);
        assertTrue(Files.exists(_confFilePath), "config file exists");
        
        var _etlFilePath = Paths.get(StartUp.CONF_DIR + File.separator + StartUp.QUERIES_FILE_NAME);
        assertTrue(Files.exists(_etlFilePath), "etl file exists");
    }

    @Test
    @DisplayName(value = "Test NAV SQL connection")
    public void TestNavSqlConnection() throws Exception{
        final var _sql = "select 1 as rezultat;";
        var _db = new DbConn();
        try(var _conn = _db.forMssql();
            var _stmt = _conn.prepareStatement(_sql);
            var _rs = _stmt.executeQuery();){
            while (_rs.next()){
                assertEquals(1, _rs.getInt("rezultat"));
                break;
            }
        }            
    }
    
    @Test
    @DisplayName(value = "Test PostgreSQL connection")
    public void TestPGSQLConnection() throws Exception{
        final var _sql = "select 1::int as rezultat;";
        var _db = new DbConn();
        try(var _conn = _db.forPgres();
            var _stmt = _conn.prepareStatement(_sql);
            var _rs = _stmt.executeQuery();){
            while (_rs.next()){
                assertEquals(1, _rs.getInt("rezultat"));
            }
        }
    }
    
    @Test
    @DisplayName(value = "Test e-mail")
    public void TestEmail() throws Exception{
        var _mail = new Mail();
        assertDoesNotThrow(() -> _mail.send("Test default recipient", "Unit Test NAV ETL", Optional.empty()), "testing mail delivery to default recipient");
        
        var _recipients = List.of("mail@example.com");
        assertDoesNotThrow(() -> _mail.send("Test explicit recipient", "Unit Test NAV ETL", Optional.of(_recipients)), "testing mail delivery to explicit recipients");
    }
    
    @Test
    @DisplayName(value = "Test ETL xml validation")
    public void TestEtlXmlValidation() throws Exception{
        var _xml = new EtlQueries();
        assertFalse(_xml.getSteps().isEmpty(), "ETL xml reading");
    }
}
