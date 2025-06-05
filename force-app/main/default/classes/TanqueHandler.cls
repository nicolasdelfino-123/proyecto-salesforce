public class TanqueHandler {
    
    public static void handleAfterInsert(List<Tanque__c> newTanques) {
        // Solo procesar si es un registro individual (no creación masiva)
        if (newTanques.size() == 1 && !System.isBatch() && !System.isFuture()) {
            Tanque__c tanque = newTanques[0];
            
            // Verificar que el tanque tenga los datos necesarios
            if (tanque.Id != null) {
                // Llamar al servicio de Bitly de forma asíncrona
                BitlyService.createShortLink(tanque.Id);
            }
        }
    }
    
    public static void handleBeforeInsert(List<Tanque__c> newTanques) {
        // Validaciones adicionales si son necesarias
        validateTanques(newTanques);
    }
    
    public static void handleBeforeUpdate(List<Tanque__c> newTanques, Map<Id, Tanque__c> oldTanqueMap) {
        // Validaciones adicionales si son necesarias
        validateTanques(newTanques);
    }
    
    private static void validateTanques(List<Tanque__c> tanques) {
        for (Tanque__c tanque : tanques) {
            // Validación de capacidad
            if (tanque.Capacidad_Litros__c != null && tanque.Capacidad_Litros__c <= 0) {
                tanque.addError('La capacidad debe ser mayor a 0 litros.');
            }
            
            // Validación de número de serie único si es necesario
            if (String.isBlank(tanque.Numero_de_Serie__c)) {
                tanque.addError('El número de serie es obligatorio.');
            }
        }
    }
}