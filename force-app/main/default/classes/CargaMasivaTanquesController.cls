public class CargaMasivaTanquesController {
    
    @AuraEnabled 
    public static void crearTanques(String tanquesJSON) {     
        try {         
            // Deserializamos con manejo seguro de casting
            Object deserializedData = JSON.deserializeUntyped(tanquesJSON);
            List<Object> rawList = (List<Object>) deserializedData;
            List<Map<String, Object>> tanquesMap = new List<Map<String, Object>>();
            
            // Convertimos cada elemento a Map<String, Object>
            for (Object obj : rawList) {
                tanquesMap.add((Map<String, Object>) obj);
            }
            
            // Crear un mapa de nombres de tipos a IDs para búsqueda rápida
            Set<String> nombresTipos = new Set<String>();
            for (Map<String, Object> tMap : tanquesMap) {
                String tipoNombre = (String) tMap.get('tipo');
                if (String.isNotBlank(tipoNombre)) {
                    nombresTipos.add(tipoNombre.trim());
                }
            }
            
            // Buscar los tipos existentes
            Map<String, Id> mapaNombreATipoId = new Map<String, Id>();
            if (!nombresTipos.isEmpty()) {
                List<Tipo_de_Tanque__c> tiposExistentes = [
                    SELECT Id, Name 
                    FROM Tipo_de_Tanque__c 
                    WHERE Name IN :nombresTipos
                ];
                
                for (Tipo_de_Tanque__c tipo : tiposExistentes) {
                    mapaNombreATipoId.put(tipo.Name, tipo.Id);
                }
                
                // Identificar tipos que no existen y crearlos
                Set<String> tiposNoEncontrados = new Set<String>();
                for (String nombreTipo : nombresTipos) {
                    if (!mapaNombreATipoId.containsKey(nombreTipo)) {
                        tiposNoEncontrados.add(nombreTipo);
                    }
                }
                
                // Crear los tipos de tanque que no existen
                if (!tiposNoEncontrados.isEmpty()) {
                    List<Tipo_de_Tanque__c> nuevosTypes = new List<Tipo_de_Tanque__c>();
                    
                    for (String nombreTipo : tiposNoEncontrados) {
                        Tipo_de_Tanque__c nuevoTipo = new Tipo_de_Tanque__c();
                        nuevoTipo.Name = nombreTipo;
                        // Si tienes más campos obligatorios en Tipo_de_Tanque__c, agrégalos aquí
                        nuevosTypes.add(nuevoTipo);
                    }
                    
                    // Insertar los nuevos tipos
                    insert nuevosTypes;
                    
                    // Agregar los nuevos tipos al mapa
                    for (Tipo_de_Tanque__c nuevoTipo : nuevosTypes) {
                        mapaNombreATipoId.put(nuevoTipo.Name, nuevoTipo.Id);
                    }
                    
                    System.debug('Tipos de tanque creados automáticamente: ' + tiposNoEncontrados);
                }
            }
            
            List<Tanque__c> tanquesAInsertar = new List<Tanque__c>();          
            
            for (Map<String, Object> tMap : tanquesMap) {             
                Tanque__c tanque = new Tanque__c();             
                tanque.Numero_de_Serie__c = (String) tMap.get('numeroSerie');                          
                
                // Hay que castear los números porque JSON los interpreta como Double             
                if(tMap.get('capacidad') != null) {                 
                    tanque.Capacidad_Litros__c = Decimal.valueOf(String.valueOf(tMap.get('capacidad')));             
                }             
                if(tMap.get('precio') != null) {                 
                    tanque.Precio__c = Decimal.valueOf(String.valueOf(tMap.get('precio')));             
                }                          
                
                tanque.Estado__c = (String) tMap.get('estado');
                
                // Asignar el tipo de tanque (ahora siempre existe porque se crea automáticamente)
                String tipoNombre = (String) tMap.get('tipo');
                if (String.isNotBlank(tipoNombre)) {
                    tipoNombre = tipoNombre.trim();
                    Id tipoId = mapaNombreATipoId.get(tipoNombre);
                    
                    if (tipoId != null) {
                        tanque.Tipo_de_Tanque__c = tipoId;
                    } else {
                        // Esto no debería pasar ya que creamos automáticamente los tipos faltantes
                        throw new AuraHandledException('Error interno: No se pudo asignar el tipo "' + tipoNombre + '"');
                    }
                }
                
                tanquesAInsertar.add(tanque);         
            }          
            
            insert tanquesAInsertar;
            
            System.debug('Tanques creados exitosamente: ' + tanquesAInsertar.size());
            
        } catch (Exception e) {         
            throw new AuraHandledException('Error creando tanques: ' + e.getMessage());     
        } 
    }
}