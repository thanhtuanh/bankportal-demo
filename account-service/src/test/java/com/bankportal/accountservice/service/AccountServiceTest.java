package com.bankportal.accountservice.service;

import com.bankportal.accountservice.repository.AccountRepository;
import com.bankportal.accountservice.model.Account;
import com.bankportal.accountservice.dto.AccountDto;
import com.bankportal.accountservice.dto.TransferRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit-Tests für AccountService mit JUnit 5 + Mockito (ohne Spring Context).
 * Hinweise:
 * - Bleibt bei deiner bestehenden Struktur (Package, Klassen, int-Balance).
 * - Prüft Mapping Account <-> AccountDto, Fehlerfälle und einen erfolgreichen Transfer.
 */
@ExtendWith(MockitoExtension.class)
class AccountServiceTest {

    @Mock
    AccountRepository repo;

    @InjectMocks
    AccountService service;

    Account max;   // Beispiel-Dummy
    Account anna;  // Beispiel-Dummy

    @BeforeEach
    void setUp() {
        max = new Account();
        max.setId(1L);
        max.setOwner("Max");
        max.setBalance(100);

        anna = new Account();
        anna.setId(2L);
        anna.setOwner("Anna");
        anna.setBalance(200);
    }

    @Test
    void getAllAccounts_gibtDtosZurueck() {
        when(repo.findAll()).thenReturn(Arrays.asList(max));

        List<AccountDto> result = service.getAllAccounts();

        assertEquals(1, result.size(), "Es sollte genau 1 Konto geben");
        assertEquals("Max", result.get(0).getOwner());
        assertEquals(100, result.get(0).getBalance());
        verify(repo, times(1)).findAll();
        verifyNoMoreInteractions(repo);
    }

    @Test
    void createAccount_legtdatenAnUndGibtDtoZurueck() {
        // Eingabedaten (DTO)
        AccountDto dto = new AccountDto();
        dto.setOwner("Anna");
        dto.setBalance(200);

        // Repo-Save simuliert persistierte Entität (z. B. mit gesetzter ID)
        when(repo.save(any(Account.class))).thenAnswer(inv -> {
            Account a = inv.getArgument(0);
            a.setId(99L);
            return a;
        });

        AccountDto created = service.createAccount(dto);

        assertNotNull(created);
        assertEquals("Anna", created.getOwner());
        assertEquals(200, created.getBalance());
        // Optional: Wenn createAccount die neue ID zurückgeben sollte, hier prüfen:
        // assertEquals(99L, created.getId());

        // Prüfen, dass das Repository mit einer Account-Entität aufgerufen wurde, die dem DTO entspricht
        ArgumentCaptor<Account> captor = ArgumentCaptor.forClass(Account.class);
        verify(repo).save(captor.capture());
        Account saved = captor.getValue();
        assertEquals("Anna", saved.getOwner());
        assertEquals(200, saved.getBalance());
        verifyNoMoreInteractions(repo);
    }

    @Test
    void transfer_wirftWennSenderNichtGefunden() {
        TransferRequest req = new TransferRequest();
        req.setFromAccountId(1L);
        req.setToAccountId(2L);
        req.setAmount(100);

        when(repo.findById(1L)).thenReturn(Optional.empty()); // Sender nicht gefunden

        Exception ex = assertThrows(RuntimeException.class, () -> service.transfer(req));
        assertTrue(ex.getMessage().toLowerCase().contains("sender"), "Fehlermeldung sollte Sender erwähnen");
        verify(repo).findById(1L);
        verifyNoMoreInteractions(repo);
    }

    @Test
    void transfer_wirftWennEmpfaengerNichtGefunden() {
        TransferRequest req = new TransferRequest();
        req.setFromAccountId(1L);
        req.setToAccountId(2L);
        req.setAmount(50);

        when(repo.findById(1L)).thenReturn(Optional.of(max));      // Sender vorhanden
        when(repo.findById(2L)).thenReturn(Optional.empty());      // Empfänger fehlt

        Exception ex = assertThrows(RuntimeException.class, () -> service.transfer(req));
        assertTrue(ex.getMessage().toLowerCase().contains("empfänger")
                || ex.getMessage().toLowerCase().contains("empfaenger"),
                "Fehlermeldung sollte Empfänger erwähnen");

        verify(repo, times(1)).findById(1L);
        verify(repo, times(1)).findById(2L);
        verifyNoMoreInteractions(repo);
    }

    @Test
    void transfer_wirftWennNichtGenugGuthaben() {
        TransferRequest req = new TransferRequest();
        req.setFromAccountId(1L);
        req.setToAccountId(2L);
        req.setAmount(100); // Max hat nur 100 -> Grenzfall; passe ggf. auf 101 an, falls Service strikt > prüft

        // Setze bewusst zu kleines Guthaben
        max.setBalance(50);

        when(repo.findById(1L)).thenReturn(Optional.of(max));
        when(repo.findById(2L)).thenReturn(Optional.of(anna));

        Exception ex = assertThrows(RuntimeException.class, () -> service.transfer(req));
        assertTrue(ex.getMessage().toLowerCase().contains("nicht genügend")
                || ex.getMessage().toLowerCase().contains("nicht genug"),
                "Fehlermeldung sollte mangelndes Guthaben erwähnen");

        verify(repo, times(1)).findById(1L);
        verify(repo, times(1)).findById(2L);
        // Kein save(), weil Transaktion abgebrochen
        verify(repo, never()).save(any(Account.class));
        verifyNoMoreInteractions(repo);
    }

    @Test
    void transfer_buchtBetragUmUndSpeichertBeideKonten() {
        // Erfolgreicher Transfer 80 von Max -> Anna
        TransferRequest req = new TransferRequest();
        req.setFromAccountId(1L);
        req.setToAccountId(2L);
        req.setAmount(80);

        max.setBalance(150);
        anna.setBalance(20);

        when(repo.findById(1L)).thenReturn(Optional.of(max));
        when(repo.findById(2L)).thenReturn(Optional.of(anna));
        when(repo.save(any(Account.class))).thenAnswer(inv -> inv.getArgument(0)); // passt gespeichertes Objekt durch

        // Act
        service.transfer(req);

        // In-Memory Salden prüfen
        assertEquals(70, max.getBalance(), "Sender-Saldo muss reduziert sein");
        assertEquals(100, anna.getBalance(), "Empfänger-Saldo muss erhöht sein");

        // Es sollten zwei Saves erfolgt sein: Sender + Empfänger
        ArgumentCaptor<Account> captor = ArgumentCaptor.forClass(Account.class);
        verify(repo, times(2)).save(captor.capture());
        List<Account> savedEntities = captor.getAllValues();

        // IDs prüfen (Reihenfolge egal)
        assertTrue(savedEntities.stream().anyMatch(a -> a.getId().equals(1L) && a.getBalance() == 70));
        assertTrue(savedEntities.stream().anyMatch(a -> a.getId().equals(2L) && a.getBalance() == 100));

        verify(repo, times(1)).findById(1L);
        verify(repo, times(1)).findById(2L);
        verifyNoMoreInteractions(repo);
    }
}
