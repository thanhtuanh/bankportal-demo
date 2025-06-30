import { Component } from '@angular/core';
import { AccountListComponent } from '../account-list/account-list.component';
import { NavigationComponent } from '../navigation/navigation.component';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [AccountListComponent, NavigationComponent],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent {}
