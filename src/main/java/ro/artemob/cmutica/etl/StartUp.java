package ro.any.catalin.etl;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.FileTime;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import java.util.logging.FileHandler;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;
import java.util.logging.Logger;

/**
 *
 * @author catalin
 */
public class StartUp {
    public static final String LINE_SEPARATOR = System.getProperty("line.separator");
    public static final String CONF_DIR = System.getProperty("user.home") + File.separator + ".nav_etl";
    public static final String LOG_DIR_NAME = File.separator + "logs";
    public static final DateFormat TIMESTAMP_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    public static final DateFormat DATE_FORMAT_FILE = new SimpleDateFormat("yyyyMMdd");
    public static final String QUERIES_FILE_NAME = "queries.xml";
    public static final String XSD_FILE_NAME = "queries.xsd";
    public static final String CONF_PROPS_FILE_NAME = "base.conf";
    
    private static void setConsoleLogFormat(){
        System.setProperty("java.util.logging.SimpleFormatter.format", "%1$tF %1$tT %4$s %2$s: %5$s%6$s%n");
    }
    
    private static void initConfDirectoryStructure() throws Exception{
        var _logDir = Paths.get(CONF_DIR + LOG_DIR_NAME + File.separator);
        if (!Files.exists(_logDir)) Files.createDirectories(_logDir);
    }
    
    private static void initDefaultConfFiles(String fileName) throws Exception{
        try(var istream = StartUp.class.getClassLoader().getResourceAsStream(fileName);){
            var _confFile = Paths.get(CONF_DIR + File.separator + fileName);
            if (!Files.exists(_confFile)){
                Files.copy(istream, _confFile);
            }
        }
    }
    
    private static void deleteOldLogFiles() throws Exception{
        var _path = Paths.get(CONF_DIR + LOG_DIR_NAME);
        var _now = new Date().getTime();
        var _age = FileTime.from(_now - 60L * 24L * 60L * 60L * 1000L, TimeUnit.DAYS);
        Files.walk(_path)
                .forEach(x -> {
                    try {
                        if (Files.isRegularFile(x) && Files.getLastModifiedTime(x).compareTo(_age) >= 0)
                            Files.delete(x);
                    } catch (IOException ex) {
                        throw new RuntimeException(ex);
                    }
                });
    }
    
    private static void configParentLogger() throws Exception{
        var logFormatter = new Formatter() {
            @Override
            public String format(LogRecord lr) {
                var _rezultat = TIMESTAMP_FORMAT.format(new Date(lr.getMillis())) + " || " + lr.getLevel() + " || " + lr.getSourceClassName() + " - " +
                        lr.getSourceMethodName() + " || ";
                if (lr.getThrown() == null){
                    _rezultat += lr.getMessage() + LINE_SEPARATOR;
                } else {
                    _rezultat += lr.getThrown().getClass().getName() + ": " + lr.getThrown().getMessage() + LINE_SEPARATOR;
                    for (var elem : lr.getThrown().getStackTrace()){
                        _rezultat += "\tat " + elem.getClassName() + " -> " + elem.getMethodName() + ": " + elem.getLineNumber() + LINE_SEPARATOR;
                    }
                }
                return _rezultat;
            }
        };
        var _logDir = Paths.get(CONF_DIR + LOG_DIR_NAME + File.separator);
        var _fileHandler = new FileHandler(_logDir.toString() + File.separator + DATE_FORMAT_FILE.format(new Date()) + "_%g.log", true);
        _fileHandler.setFormatter(logFormatter);
        Logger.getLogger("").addHandler(_fileHandler);
    }
    
    public static void init() throws Exception{
        initConfDirectoryStructure();
        initDefaultConfFiles(CONF_PROPS_FILE_NAME);
        initDefaultConfFiles(XSD_FILE_NAME);
        initDefaultConfFiles(QUERIES_FILE_NAME);
        deleteOldLogFiles();
        setConsoleLogFormat();
        configParentLogger();
    }
}
