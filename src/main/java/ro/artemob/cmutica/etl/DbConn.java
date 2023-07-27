package ro.any.catalin.etl;

import com.microsoft.sqlserver.jdbc.SQLServerDataSource;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.util.Properties;
import org.postgresql.ds.PGSimpleDataSource;
import ro.catalin.crypto.impl.Crypto;

/**
 *
 * @author catalin
 */
public class DbConn {
    private final SQLServerDataSource mssqlDs;
    private final PGSimpleDataSource pgresDs;

    public DbConn() throws Exception {
        
        //obtinere parametri configurare
        var _conf = new Properties();
        try(var iStream = Files.newInputStream(Paths.get(StartUp.CONF_DIR + File.separator + StartUp.CONF_PROPS_FILE_NAME));){
            _conf.load(iStream);
        }
        
        //initializare sursa de date pentru MSSQL NAV
        this.mssqlDs = new SQLServerDataSource();   
        this.mssqlDs.setServerName(_conf.getProperty("mssql.host"));
        this.mssqlDs.setPortNumber(Integer.valueOf(_conf.getProperty("mssql.port")));
        this.mssqlDs.setDatabaseName(_conf.getProperty("mssql.database"));
        this.mssqlDs.setEncrypt(false);
        this.mssqlDs.setTrustServerCertificate(true);
        this.mssqlDs.setAuthentication("SqlPassword");
        this.mssqlDs.setUser(_conf.getProperty("mssql.user"));
        
        var _mssqlPsw = Crypto.decrypt(_conf.getProperty("mssql.password.crypt"));
        this.mssqlDs.setPassword(_mssqlPsw);
        
        //initializre sursa de date pentru Postgresql server
        this.pgresDs = new PGSimpleDataSource();
        this.pgresDs.setServerNames(new String[]{_conf.getProperty("pgres.host")});
        this.pgresDs.setPortNumbers(new int[]{Integer.valueOf(_conf.getProperty("pgres.port"))});
        this.pgresDs.setDatabaseName(_conf.getProperty("pgres.database"));
        this.pgresDs.setConnectTimeout(0);
        this.pgresDs.setUser(_conf.getProperty("pgres.user"));
        
        var _psqlPwd = Crypto.decrypt(_conf.getProperty("pgres.password.crypt"));
        this.pgresDs.setPassword(_psqlPwd);
    }

    public Connection forMssql() throws Exception{
        return this.mssqlDs.getConnection();
    }
    
    public Connection forPgres() throws Exception{
        return this.pgresDs.getConnection();
    }
}
