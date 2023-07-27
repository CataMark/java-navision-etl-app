package ro.any.catalin.etl;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.validation.SchemaFactory;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

/**
 *
 * @author catalin
 */
public class EtlQueries {
    private static final Logger LOG = Logger.getLogger(EtlQueries.class.getName());
    
    public record EtlStep(
            String name,
            Integer order,
            Optional<String> targetCallfront,
            Optional<String> sourceQuery,
            Optional<String> sourceQueryParam,
            Optional<String> targetTable,
            Optional<String> targetCallback
        ){};
    
    private static final Function<String, String> transform = (text) -> {
        var lines = text.split("\n");
        for (int i = 0; i < lines.length; i++){
            lines[i] = lines[i].trim();
        }
        return String.join(" ", lines);
    };
    
    private final List<EtlStep> steps;

    
    private Optional<String> getElementData(Optional<NodeList> node){
        return node
                .map(x -> x.item(0).getTextContent())
                .filter(x -> !x.isBlank())
                .map(x -> x.transform(transform));
    }

    public EtlQueries() throws Exception {
        this.steps = new ArrayList<>();
        
        var tmpSchemaFile = Files.createTempFile("navetl_", StartUp.XSD_FILE_NAME);
        try (var istream = StartUp.class.getClassLoader().getResourceAsStream(StartUp.XSD_FILE_NAME);) {
            Files.copy(istream, tmpSchemaFile, StandardCopyOption.REPLACE_EXISTING);
        }
        /*configure readers and validators */
        var schema = SchemaFactory.newDefaultInstance().newSchema(tmpSchemaFile.toFile());
        var dBuilderFactory = DocumentBuilderFactory.newInstance();
        dBuilderFactory.setSchema(schema);
        dBuilderFactory.setNamespaceAware(true);
        
        var dBuilder = dBuilderFactory.newDocumentBuilder();
        dBuilder.setErrorHandler(new ErrorHandler(){
            @Override
            public void warning(SAXParseException exception) throws SAXException {
                LOG.log(Level.WARNING, null, exception);
            }

            @Override
            public void error(SAXParseException exception) throws SAXException {
                throw exception;
            }

            @Override
            public void fatalError(SAXParseException exception) throws SAXException {
                throw exception;
            }
        });
        
        var document = dBuilder.parse(Paths.get(StartUp.CONF_DIR + File.separator + StartUp.QUERIES_FILE_NAME).toString());
        document.getDocumentElement().normalize();
        
        /* read the etl steps */
        var _steps = document.getElementsByTagName("step");
        for (var i = 0; i < _steps.getLength(); i++){
            var _item = _steps.item(i);
            var _etlStep = switch(_item.getNodeType()){
                case Node.ELEMENT_NODE:
                    var _x = (Element) _item;
                    yield new EtlStep(
                            Optional.ofNullable(_x.getAttribute("name"))
                                    .filter(x -> !x.isBlank())
                                    .orElseThrow(() -> new Exception("Pasul nu are un nume!")),
                            Optional.ofNullable(_x.getAttribute("order"))
                                    .filter(x -> !x.isBlank())
                                    .map(x -> Integer.valueOf(x))
                                    .orElseThrow(() -> new Exception("Pasul nu are un numar de ordine!")),
                            getElementData(Optional.ofNullable(_x.getElementsByTagName("targetCallfront"))),
                            getElementData(Optional.ofNullable(_x.getElementsByTagName("sourceQuery"))),
                            getElementData(Optional.ofNullable(_x.getElementsByTagName("sourceQueryParam"))),
                            getElementData(Optional.ofNullable(_x.getElementsByTagName("targetTable"))),
                            getElementData(Optional.ofNullable(_x.getElementsByTagName("targetCallback")))
                    );
                default:
                    throw new Exception("This node is not an element!");
            };
            
            this.steps.add(_etlStep);
        }
        this.steps.sort((x, y) -> x.order.compareTo(y.order));
    }

    public List<EtlStep> getSteps() {
        return this.steps;
    }
}
