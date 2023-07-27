package ro.any.catalin.etl;

import java.math.BigInteger;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.Date;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import ro.any.catalin.etl.EtlQueries.EtlStep;

/**
 *
 * @author catalin
 */
public class Main {
    private static final Logger LOG = Logger.getLogger(Main.class.getName());    
    private static final int BATCH_SIZE = 1000;
    
    private static void executeCallFront(Connection pgconn, EtlStep step) throws Exception{
        if (step.targetCallfront().isPresent()) {
            try(var _stmt = pgconn.prepareStatement(step.targetCallfront().get());){
                _stmt.execute();
            }
            LOG.log(Level.INFO, String.format("%s -> callfront executed.", step.name()));
        }
    }
    
    private static BigInteger getParameterValue(Connection pgconn, EtlStep step) throws Exception{
        var _rezultat = BigInteger.valueOf(0);
        if (step.sourceQueryParam().isPresent()){
            try (var _stmt = pgconn.prepareStatement(step.sourceQueryParam().get());
                var _rs = _stmt.executeQuery();){
                
                while (_rs.next()){
                    _rezultat = _rs.getObject(1, BigInteger.class);
                    break;
                }
            }
        }
        LOG.log(Level.INFO, String.format("%s -> parameter obtained.", step.name()));
        return _rezultat;
    }
    
    private static void executeEtl(Connection msconn, Connection pgconn, EtlStep step) throws Exception{
        if (step.sourceQuery().isEmpty() || step.targetTable().isEmpty()) return;
        
        PreparedStatement _msstmt = null;
        ResultSet _msrs = null;
        PreparedStatement _pgstmtetl = null;
        
        try {
            //geting the NAV SQL records and metadata
            _msstmt = msconn.prepareStatement(step.sourceQuery().get());
            if (step.sourceQueryParam().isPresent()) _msstmt.setObject(1, getParameterValue(pgconn, step), Types.BIGINT);
            
            _msrs = _msstmt.executeQuery();
            var _meta = _msrs.getMetaData();
            
            //setting the Postgresql prepared statement components;
            var _columnString = "";
            var _paramString = "";
            
            for (int i = 1; i <= _meta.getColumnCount(); i++){
                if (i > 1){
                    _columnString += ",";
                    _paramString += ",";
                }
                _columnString += "\"" + _meta.getColumnName(i) + "\"";
                _paramString += "?";
            }
            var _insertSQL = "insert into " + step.targetTable().get() + " (" + _columnString + ") values (" + _paramString + ");";
            
            //executing the etl
            _pgstmtetl = pgconn.prepareStatement(_insertSQL);
            var _contor = 0L;
            var _pozProcesate = 0L;
            while (_msrs.next()){
                for (int i = 1; i <= _meta.getColumnCount(); i++){
                    var _sqlType = switch ( _meta.getColumnType(i)){
                        case Types.NVARCHAR:
                            yield Types.VARCHAR;
                        case Types.NCHAR:
                            yield Types.CHAR;
                        default:
                            yield _meta.getColumnType(i);
                    };                        
                    _pgstmtetl.setObject(i, _msrs.getObject(i), _sqlType);
                }
                _pgstmtetl.addBatch();
                if (++_contor % BATCH_SIZE == 0)
                    _pozProcesate += _pgstmtetl.executeBatch().length;
            }
            _pozProcesate += _pgstmtetl.executeBatch().length;
            LOG.log(Level.INFO, String.format("%1$s -> %2$d pozitii", step.name(), _pozProcesate));            
        } finally {
            if (_pgstmtetl != null) _pgstmtetl.close();
            if (_msrs != null) _msrs.close();
            if (_msstmt != null) _msstmt.close();
        }
    }
    
    private static void executeCallback (Connection pgconn, EtlStep step) throws Exception{
        if (step.targetCallback().isPresent()){
            try (var _stmt = pgconn.prepareStatement(step.targetCallback().get());){
                _stmt.execute();
            }
            LOG.log(Level.INFO, String.format("%s -> callback executed.", step.name()));
        }
    }
    
    private static void process(Connection msconn, Connection pgconn, EtlStep step) throws Exception{
        LOG.log(Level.INFO, "***********************************");
        executeCallFront(pgconn, step);
        executeEtl(msconn, pgconn, step);
        executeCallback(pgconn, step);
    }
    
    public static void main(String[] args) {
        try {
            StartUp.init();
            
            var _cons = new DbConn();
            var _queries = new EtlQueries();
            var _start = new Date();           
                
            for (var step : _queries.getSteps()){
                try(var _msconn = _cons.forMssql();
                    var _pgconn = _cons.forPgres();){
                    
                    process(_msconn, _pgconn, step);
                }
            }
            var _end = new Date();
            var _diff = TimeUnit.SECONDS.convert(_end.getTime() - _start.getTime(), TimeUnit.MILLISECONDS);
            LOG.log(Level.INFO, String.format("Sync duration: %d sec", _diff));
            
            var _mail = new Mail();
            _mail.send("Sync finished", String.format("Duration %d sec", _diff), Optional.empty());
            
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, ex.getMessage(), ex);
        }
    }
}
