@isTest
public class TanqueHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Crear Tipo de Tanque de prueba
        Tipo_de_Tanque__c tipoTanque = new Tipo_de_Tanque__c(
            Name = 'Tanque Estándar Test'
        );
        insert tipoTanque;
    }
    
    @isTest
    static void testSingleTanqueInsert() {
        Tipo_de_Tanque__c tipoTanque = [SELECT Id FROM Tipo_de_Tanque__c LIMIT 1];
        
        // Mock para Bitly
        Test.setMock(HttpCalloutMock.class, new BitlyMockResponse());
        
        // Crear un solo tanque
        Tanque__c tanque = new Tanque__c(
            Name = 'Tanque Individual',
            Capacidad_Litros__c = 2000,
            Numero_de_Serie__c = 'SINGLE001',
            Tipo_de_Tanque__c = tipoTanque.Id
        );
        
        Test.startTest();
        insert tanque;
        Test.stopTest();
        
        // Verificar que el tanque fue insertado
        List<Tanque__c> insertedTanques = [SELECT Id, Name FROM Tanque__c WHERE Id = :tanque.Id];
        System.assertEquals(1, insertedTanques.size());
        System.assertEquals('Tanque Individual', insertedTanques[0].Name);
    }
    
    @isTest
    static void testMultipleTanqueInsert() {
        Tipo_de_Tanque__c tipoTanque = [SELECT Id FROM Tipo_de_Tanque__c LIMIT 1];
        
        // Crear múltiples tanques
        List<Tanque__c> tanques = new List<Tanque__c>();
        for (Integer i = 0; i < 3; i++) {
            tanques.add(new Tanque__c(
                Name = 'Tanque Múltiple ' + i,
                Capacidad_Litros__c = 1500,
                Numero_de_Serie__c = 'MULTI00' + i,
                Tipo_de_Tanque__c = tipoTanque.Id
            ));
        }
        
        Test.startTest();
        // Inserción masiva - no debería disparar Bitly
        insert tanques;
        Test.stopTest();
        
        // Verificar que todos los tanques fueron insertados
        List<Tanque__c> insertedTanques = [SELECT Id FROM Tanque__c WHERE Name LIKE 'Tanque Múltiple%'];
        System.assertEquals(3, insertedTanques.size());
    }
    
    @isTest
    static void testTanqueValidationCapacidadNegativa() {
        Tipo_de_Tanque__c tipoTanque = [SELECT Id FROM Tipo_de_Tanque__c LIMIT 1];
        
        // Crear tanque con capacidad negativa
        Tanque__c tanque = new Tanque__c(
            Name = 'Tanque Inválido',
            Capacidad_Litros__c = -100,
            Numero_de_Serie__c = 'INVALID001',
            Tipo_de_Tanque__c = tipoTanque.Id
        );
        
        Test.startTest();
        try {
            insert tanque;
            System.assert(false, 'Debería haber lanzado excepción por capacidad negativa');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('La capacidad debe ser mayor a 0 litros'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testTanqueValidationSinNumeroSerie() {
        Tipo_de_Tanque__c tipoTanque = [SELECT Id FROM Tipo_de_Tanque__c LIMIT 1];
        
        // Crear tanque sin número de serie
        Tanque__c tanque = new Tanque__c(
            Name = 'Tanque Sin Serie',
            Capacidad_Litros__c = 1000,
            Tipo_de_Tanque__c = tipoTanque.Id
        );
        
        Test.startTest();
        try {
            insert tanque;
            System.assert(false, 'Debería haber lanzado excepción por falta de número de serie');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('El número de serie es obligatorio'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testTanqueUpdate() {
        Tipo_de_Tanque__c tipoTanque = [SELECT Id FROM Tipo_de_Tanque__c LIMIT 1];
        
        // Crear y insertar tanque
        Tanque__c tanque = new Tanque__c(
            Name = 'Tanque Para Update',
            Capacidad_Litros__c = 1000,
            Numero_de_Serie__c = 'UPDATE001',
            Tipo_de_Tanque__c = tipoTanque.Id
        );
        insert tanque;
        
        // Actualizar el tanque
        tanque.Capacidad_Litros__c = 1500;
        
        Test.startTest();
        update tanque;
        Test.stopTest();
        
        // Verificar la actualización
        Tanque__c updatedTanque = [SELECT Capacidad_Litros__c FROM Tanque__c WHERE Id = :tanque.Id];
        System.assertEquals(1500, updatedTanque.Capacidad_Litros__c);
    }
    
    // Mock HTTP Response para las pruebas
    public class BitlyMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"link": "https://bit.ly/testlink"}');
            res.setStatusCode(201);
            return res;
        }
    }
}