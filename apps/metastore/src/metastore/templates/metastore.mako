## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from django.utils.html import escape
from desktop import conf
from desktop.lib.i18n import smart_unicode
from desktop.views import commonheader, commonfooter, _ko
from django.utils.translation import ugettext as _
%>

<%namespace name="actionbar" file="actionbar.mako" />
<%namespace name="components" file="components.mako" />
<%namespace name="assist" file="/assist.mako" />
<%namespace name="tableStats" file="/table_stats.mako" />
<%namespace name="require" file="/require.mako" />

${ commonheader(_("Metastore"), app_name, user) | n,unicode }
${ components.menubar() }

${ require.config() }

${ tableStats.tableStats() }
${ assist.assistPanel() }

<link rel="stylesheet" href="${ static('desktop/ext/css/bootstrap-editable.css') }">
<link rel="stylesheet" href="${ static('metastore/css/metastore.css') }" type="text/css">
<link rel="stylesheet" href="${ static('notebook/css/notebook.css') }">
<style type="text/css">
% if conf.CUSTOM.BANNER_TOP_HTML.get():
  .show-assist {
    top: 110px!important;
  }
  .main-content {
    top: 112px!important;
  }
% endif
</style>

<script src="${ static('desktop/ext/js/bootstrap-editable.min.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/ext/js/d3.v3.js') }" type="text/javascript" charset="utf-8"></script>

<script type="text/html" id="metastore-breadcrumbs">
  <ul class="nav nav-pills hueBreadcrumbBar" id="breadcrumbs">
    <li>
      <i class="fa fa-th muted"></i>
    </li>
    <li>
      <a href="javascript:void(0);" data-bind="click: databasesBreadcrumb">${_('Databases')}</a>
      <!-- ko if: database -->
      <span class="divider">&gt;</span>
      <!-- /ko -->
    </li>
    <!-- ko with: database -->
    <li>
      <a href="javascript:void(0);" data-bind="text: name, click: $root.tablesBreadcrumb"></a>
      <!-- ko if: table -->
      <span class="divider">&gt;</span>
      <!-- /ko -->
    </li>
    <!-- ko with: table -->
    <li>
      <span style="padding-left:12px" data-bind="text: name"></span>
    </li>
    <!-- /ko -->
    <!-- /ko -->
  </ul>
</script>

<script type="text/html" id="metastore-columns-table">
  <table class="table table-striped table-condensed sampleTable">
    <thead>
    <tr>
      <th width="1%">&nbsp;</th>
      ## no stats for partition key type
      <th width="1%" class="no-sort">&nbsp;</th>
      <th width="1%">&nbsp;</th>
      <th>${_('Name')}</th>
      <th>${_('Type')}</th>
      <th>${_('Comment')}</th>
    </tr>
    </thead>
    <tbody data-bind="foreach: $data">
      <tr>
        ## start at 0
        <td data-bind="text: $index()+1"></td>
        ## no stats for partition key type
        <td>
         <span class="blue" data-bind="component: { name: 'table-stats', params: {
            alwaysActive: true,
            statsVisible: true,
            sourceType: 'hive',
            databaseName: table.database.name,
            tableName: table.name,
            columnName: name,
            fieldType: type,
            assistHelper: table.assistHelper
          } }"></span>
        </td>
        <td class="pointer" data-bind="click: function() { favourite(!favourite()) }"><i style="color: #338bb8" class="fa" data-bind="css: {'fa-star': favourite, 'fa-star-o': !favourite() }"></i></td>
        <td title="${ _("Scroll to the column") }">
          <a href="javascript:void(0)" class="column-selector" data-bind="text: name"></a>
        </td>
        <td data-bind="text: type"></td>
        <td>
          <span data-bind="editable: comment, editableOptions: {enabled: true, placement: 'left', emptytext: '${ _ko('Add a comment...') }' }" class="editable editable-click editable-empty">
            ${ _('Add a comment...') }</span>
        </td>
      </tr>
    </tbody>
  </table>
</script>

<script type="text/html" id="metastore-partition-columns-table">
  <div style="overflow: auto">
    <table id="sampleTable" class="table table-striped table-condensed sampleTable">
      <thead>
        <tr>
          <th style="width: 10px"></th>
          <th>${_('Name')}</th>
          <th>${_('Type')}</th>
        </tr>
      </thead>
      <tbody>
      <!-- ko foreach: detailedKeys -->
      <tr>
        <td data-bind="text: $index()+1"></td>
        <td data-bind="text: $data.name"></td>
        <td data-bind="text: $data.type"></td>
      </tr>
      <!-- /ko -->
      </tbody>
    </table>
  </div>
</script>

<script type="text/html" id="metastore-partition-values-table">
  <div style="overflow: auto">
    <table id="sampleTable" class="table table-striped table-condensed sampleTable">
      <thead>
        <tr>
          <th style="width: 10px"></th>
          <th>${_('Values')}</th>
          <th>${_('Spec')}</th>
          <th>${_('Browse')}</th>
        </tr>
      </thead>
      <tbody>
      <!-- ko foreach: values -->
      <tr>
        <td data-bind="text: $index()+1"></td>
        <td><a data-bind="attr: {'href': readUrl }, text: '[\'' + columns.join('\',\'') + '\']'"></a></td>
        <td data-bind="text: partitionSpec"></td>
        <td>
          <a data-bind="attr: {'href': readUrl }"><i class="fa fa-th"></i> ${_('Data')}</a>
          <a data-bind="attr: {'href': browseUrl }"><i class="fa fa-file-o"></i> ${_('Files')}</a>
        </td>
      </tr>
      <!-- /ko -->
      </tbody>
    </table>
  </div>
</script>

<script type="text/html" id="metastore-samples-table">
  <div style="overflow: auto">
    <table id="sampleTable" class="table table-striped table-condensed sampleTable">
      <thead>
        <tr>
          <th style="width: 10px"></th>
          <!-- ko foreach: headers -->
          <th data-bind="text: $data"></th>
          <!-- /ko -->
        </tr>
      </thead>
      <tbody>
        <!-- ko foreach: rows -->
          <tr>
            <td data-bind="text: $index()+1"></td>
            <!-- ko foreach: $data -->
              <td data-bind="text: $data"></td>
            <!-- /ko -->
          </tr>
        <!-- /ko -->
      </tbody>
    </table>
  </div>

  <div id="jumpToColumnAlert" class="alert hide" style="margin-top: 12px;">
    <button type="button" class="close" data-dismiss="alert">&times;</button>
    <strong>${_('Did you know?')}</strong>
    <ul>
      <li>${ _('If the sample contains a large number of columns, click a row to select a column to jump to') }</li>
    </ul>
  </div>
</script>

<script type="text/html" id="metastore-table-stats">
  <!-- ko with: tableDetails -->
  <h4>${ _('Stats') }
    <!-- ko if: $parent.refreshingTableStats -->
    <i class="fa fa-refresh fa-spin"></i>
    <!-- /ko -->
    <!-- ko ifnot: $parent.refreshingTableStats() || is_view  -->
    <a class="pointer" href="javascript: void(0);" data-bind="click: $parent.refreshTableStats"><i class="fa fa-refresh"></i></a>
    <!-- /ko -->
    <span data-bind="visible: !details.stats.COLUMN_STATS_ACCURATE && !is_view" rel="tooltip" data-placement="top" title="${ _('The column stats for this table are not accurate') }"><i class="fa fa-exclamation-triangle"></i></span>
  </h4>
  <div class="row-fluid">
    <div class="span6">
      <div title="${ _('Owner') }">
        <a data-bind="{attr: { 'href': '/useradmin/users/view/' + details.properties.owner } }">
          <i class="fa fa-fw fa-user muted"></i> <span data-bind="text: details.properties.owner"></span>
        </a>
      </div>
      <div title="${ _('Created') }"><i class="fa fa-fw fa-clock-o muted"></i> <span data-bind="text: details.properties.create_time"></span></div>
      <div title="${ _('Format') }"><i class="fa fa-fw fa-file-o muted"></i> <span data-bind="text: details.properties.format"></span></div>
      <div title="${ _('Compressed?') }"><i class="fa fa-fw fa-archive muted"></i> <span data-bind="visible: details.properties.compressed" style="display:none;">${_('Compressed')}</span><span data-bind="visible: !details.stats.compressed" style="display:none;">${_('Not compressed')}</span></div>
    </div>

    <div class="span6">
      <div><a data-bind="attr: {'href': hdfs_link, 'rel': path_location }"><i class="fa fa-fw fa-hdd-o"></i> ${_('Location')}</a></div>
      <!-- ko if: $parent.tableStats  -->
        <!-- ko with: $parent.tableStats -->
          <!-- ko if: typeof numFiles !== 'undefined'  -->
            <div title="${ _('Number of files') }"><i class="fa fa-fw fa-files-o muted"></i> <span data-bind="text: numFiles"></span></div>
          <!-- /ko -->
          <!-- ko if: typeof numRows !== 'undefined'  -->
            <div title="${ _('Number of rows') }"><i class="fa fa-fw fa-list muted"></i> <span data-bind="text: numRows"></span></div>
          <!-- /ko -->
          <!-- ko if: typeof totalSize !== 'undefined'  -->
            <div title="${ _('Total size') }"><i class="fa fa-fw fa-tasks muted"></i> <span data-bind="text: totalSize"></span></div>
          <!-- /ko -->
        <!-- /ko -->
      <!-- /ko -->
    </div>
  </div>
  <!-- /ko -->
</script>

<a title="${_('Toggle Assist')}" class="pointer show-assist" data-bind="visible: !$root.isLeftPanelVisible() && $root.assistAvailable(), click: function() { $root.isLeftPanelVisible(true); }">
  <i class="fa fa-chevron-right"></i>
</a>

<script type="text/html" id="metastore-databases">
  <div class="actionbar-actions">
    <input class="input-xlarge search-query margin-left-10" type="text" placeholder="${ _('Search for a database...') }" data-bind="clearable: databaseQuery, value: databaseQuery, valueUpdate: 'afterkeydown'"/>
    % if has_write_access:
      <button class="btn toolbarBtn margin-left-20" title="${_('Drop the selected databases')}" data-bind="click: function () { $('#dropDatabase').modal('show'); }, disable: selectedDatabases().length === 0"><i class="fa fa-times"></i>  ${_('Drop')}</button>
      <div id="dropDatabase" class="modal hide fade">
        <form id="dropDatabaseForm" action="/metastore/databases/drop" method="POST">
          ${ csrf_token(request) | n,unicode }
          <div class="modal-header">
            <a href="#" class="close" data-dismiss="modal">&times</a>
            <h3 id="dropDatabaseMessage">${ _('Do you really want to delete the database(s)?') }</h3>
          </div>
          <div class="modal-footer">
            <input type="button" class="btn" data-dismiss="modal" value="Cancel">
            <input type="submit" data-bind="click: function () { huePubSub.publish('assist.refresh'); selectedDatabases([]); return true; }" class="btn btn-danger" value="${_('Yes')}"/>
          </div>
          <!-- ko foreach: selectedDatabases -->
          <input type="hidden" name="database_selection" data-bind="value: name" />
          <!-- /ko -->
        </form>
      </div>
    % endif
  </div>
  <table id="databasesTable" class="table table-condensed datatables" style="margin-bottom: 10px">
    <thead>
    <tr>
      <th width="1%" style="text-align: center"><div class="hueCheckbox fa" data-bind="hueCheckAll: { allValues: filteredDatabases, selectedValues: selectedDatabases }"></div></th>
      <th>${ _('Database Name') }</th>
    </tr>
    </thead>
    <tbody data-bind="foreach: filteredDatabases">
    <tr>
      <td width="1%" style="text-align: center">
        <div class="hueCheckbox fa" data-bind="multiCheck: '#databasesTable', value: $data, hueChecked: $parent.selectedDatabases"></div>
      </td>
      <td>
        <a href="javascript: void(0);" data-bind="text: name, click: function () { $parent.setDatabase($data, function(){ huePubSub.publish('metastore.url.change'); }) }"></a>
      </td>
    </tr>
    </tbody>
  </table>
  <span class="margin-left-10" data-bind="visible: filteredDatabases().length === 0" style="font-style: italic; display: none;">${_('No databases found')}</span>
</script>

<script type="text/html" id="metastore-tables">
    <!-- ko if: stats  -->
    <div class="row-fluid">
      <div class="span12 tile">
        <h4>${ _('Stats') }</h4>
        <div class="row-fluid">
          <div class="span6">
            <div title="${ _('Comment') }"><i class="fa fa-fw fa-comment muted"></i>
              <!-- ko if: stats().comment -->
              <span data-bind="text: stats().comment"></span>
              <!-- /ko -->
              <!-- ko ifnot: stats().comment -->
              <i>${_('No comment.')}</i>
              <!-- /ko -->
            </div>
          </div>
          <div class="span3">
            <div title="${ _('Owner') }">
              <a data-bind="{attr: { 'href': '/useradmin/users/view/' + stats().owner_name } }">
                <i class="fa fa-fw fa-user muted"></i> <span data-bind="text: stats().owner_name"></span> (<span data-bind="text: stats().owner_type"></span>)
              </a>
            </div>
          </div>
          <div class="span3">
            <div><a data-bind="attr: {'href': stats().hdfs_link, 'rel': stats().location }"><i class="fa fa-fw fa-hdd-o"></i> ${_('Location')}</a></div>
          </div>
        </div>
        <!-- ko if: stats().parameters -->
        <div class="row-fluid">
          <div class="span12">
            <div title="${ _('Parameters') }">
              <!-- ko template: { if: stats().parameters, name: 'metastore-databases-parameters', data: hueUtils.parseHivePseudoJson(stats().parameters) }--><!-- /ko -->
            </div>
          </div>
        </div>
        <!-- /ko -->
      </div>
    </div>
    <!-- /ko -->
    <div class="row-fluid">
      <div class="span12 tile">
        <h4>${ _('Tables') }</h4>
        <div class="actionbar-actions" data-bind="visible: tables().length > 0">
          <input class="input-xlarge search-query margin-left-10" type="text" placeholder="${ _('Search for a table...') }" data-bind="clearable: tableQuery, value: tableQuery, valueUpdate: 'afterkeydown'"/>
          <button class="btn toolbarBtn margin-left-20" title="${_('Browse the selected table')}" data-bind="click: function () { setTable(selectedTables()[0]); selectedTables([]); }, disable: selectedTables().length !== 1"><i class="fa fa-eye"></i> ${_('View')}</button>
          <button class="btn toolbarBtn" title="${_('Browse the selected table')}" data-bind="click: function () { location.href = '/notebook/browse/' + name + '/' + selectedTables()[0].name; }, disable: selectedTables().length !== 1"><i class="fa fa-list"></i> ${_('Browse Data')}</button>
          % if has_write_access:
            <button id="dropBtn" class="btn toolbarBtn" title="${_('Delete the selected tables')}" data-bind="click: function () { $('#dropTable').modal('show'); }, disable: selectedTables().length === 0"><i class="fa fa-times"></i>  ${_('Drop')}</button>
            <div id="dropTable" class="modal hide fade">
              <form data-bind="attr: { 'action': '/metastore/tables/drop/' + name }" method="POST">
                ${ csrf_token(request) | n,unicode }
                <div class="modal-header">
                  <a href="#" class="close" data-dismiss="modal">&times;</a>
                  <h3 id="dropTableMessage">${_('Do you really want to drop the selected table(s)?')}</h3>
                </div>
                <div class="modal-footer">
                  <input type="button" class="btn" data-dismiss="modal" value="${_('Cancel')}" />
                  <input type="submit" data-bind="click: function () { huePubSub.publish('assist.refresh'); selectedTables([]); return true; }" class="btn btn-danger" value="${_('Yes')}"/>
                </div>
                <!-- ko foreach: selectedTables -->
                <input type="hidden" name="table_selection" data-bind="value: name" />
                <!-- /ko -->
              </form>
            </div>
          % endif
        </div>

        <table id="tablesTable" class="table table-striped table-condensed sampleTable" style="margin-bottom: 10px" data-bind="visible: tables().length > 0">
          <thead>
          <tr>
            <th width="1%" style="text-align: center"><div class="hueCheckbox fa" data-bind="hueCheckAll: { allValues: filteredTables, selectedValues: selectedTables }"></div></th>
            <th>&nbsp;</th>
            <th>${ _('Table Name') }</th>
            <th>${ _('Comment') }</th>
            <th>${ _('Type') }</th>
          </tr>
          </thead>
          <tbody data-bind="foreach: filteredTables">
            <tr>
              <td width="1%" style="text-align: center">
                <div class="hueCheckbox fa" data-bind="multiCheck: '#tablesTable', value: $data, hueChecked: $parent.selectedTables"></div>
              </td>
              <td width="1%"><span class="blue" data-bind="component: { name: 'table-stats', params: {
                  alwaysActive: true,
                  statsVisible: true,
                  sourceType: 'hive',
                  databaseName: database.name,
                  tableName: name,
                  fieldType: type,
                  assistHelper: assistHelper
                } }"></span></td>
              <td>
                <a class="tableLink" href="javascript:void(0);" data-bind="text: name, click: function() { $parent.setTable($data, function(){ huePubSub.publish('metastore.url.change'); }) }"></a>
              </td>
              <td data-bind="text: comment"></td>
              <td data-bind="text: type"></td>
            </tr>
          </tbody>
        </table>
        <span data-bind="visible: filteredTables().length === 0, css: {'margin-left-10': tables().length > 0}" style="font-style: italic; display: none;">${_('No tables found.')}</span>
      </div>
    </div>
</script>

<script type="text/html" id="metastore-databases-parameters">
  <div data-bind="toggleOverflow: {height: 24}">
    <div class="inline margin-right-20"><i class="fa fa-fw fa-cog muted"></i></div>
    <!-- ko foreach: Object.keys($data) -->
      <div class="inline margin-right-20"><strong data-bind="text: $data"></strong>: <span data-bind="text: $parent[$data]"></span></div>
    <!-- /ko -->
  </div>
</script>

<script type="text/html" id="metastore-databases-actions">
  <div class="inline-block pull-right">
    <a class="inactive-action" href="javascript:void(0)" data-bind="click: function () { huePubSub.publish('assist.refresh'); }"><i class="pointer fa fa-refresh" data-bind="css: { 'fa-spin blue' : $root.reloading }" title="${_('Refresh')}"></i></a>
    % if has_write_access:
    <a class="inactive-action margin-left-10" href="${ url('beeswax:create_database') }" title="${_('Create a new database')}"><i class="fa fa-plus-circle"></i></a>
    % endif
  </div>
</script>

<script type="text/html" id="metastore-tables-actions">
  <div class="inline-block pull-right">
    <a class="inactive-action" href="javascript:void(0)" data-bind="click: function () { huePubSub.publish('assist.refresh'); }"><i class="pointer fa fa-refresh" data-bind="css: { 'fa-spin blue' : $root.reloading }" title="${_('Refresh')}"></i></a>
    % if has_write_access:
    <a class="inactive-action margin-left-10" data-bind="attr: { 'href': '/beeswax/create/import_wizard/' + database().name }" title="${_('Create a new table from a file')}"><i class="fa fa-files-o"></i></a>
    <a class="inactive-action margin-left-10" data-bind="attr: { 'href': '/beeswax/create/create_table/' + database().name }" title="${_('Create a new table manually')}"><i class="fa fa-wrench"></i></a>
    % endif
  </div>
</script>

<script type="text/html" id="metastore-describe-table-actions">
  <div class="inline-block pull-right">
    <a class="inactive-action" href="javascript:void(0)" data-bind="click: function () { huePubSub.publish('assist.refresh'); }"><i class="pointer fa fa-refresh" data-bind="css: { 'fa-spin blue' : $root.reloading }" title="${_('Refresh')}"></i></a>
    <!-- ko with: database -->
    <!-- ko with: table -->
    <a class="inactive-action margin-left-10" href="javascript: void(0);"><i class="fa fa-star"></i></a>
    <a class="inactive-action margin-left-10" href="#" data-bind="click: showImportData" title="${_('Import Data')}"><i class="fa fa-upload"></i></a>
    <a class="inactive-action margin-left-10" data-bind="attr: { 'href': '/metastore/table/' + database.name + '/' + name + '/read' }" title="${_('Browse Data')}"><i class="fa fa-list"></i></a>
    % if has_write_access:
      <a class="inactive-action margin-left-10" href="#dropSingleTable" data-toggle="modal" data-bind="attr: { 'title' : tableDetails() && tableDetails().is_view ? '${_('Drop View')}' : '${_('Drop Table')}' }"><i class="fa fa-times"></i></a>
    % endif
    <a class="inactive-action margin-left-10" href="${ 'table.hdfs_link' }" rel="${ 'table.path_location' }" title="${_('View File Location')}"><i class="fa fa-fw fa-hdd-o"></i></a>
    <!-- ko if: tableDetails() && tableDetails().partition_keys.length -->
    <a class="inactive-action margin-left-10" data-bind="attr: { 'href': '/metastore/table/' + database.name + '/' + name + '/partitions' }" title="${_('Show Partitions')}"><i class="fa fa-sitemap"></i></a>
    <!-- /ko -->
    <!-- /ko -->
    <!-- /ko -->
  </div>
</script>

<script type="text/html" id="metastore-describe-table">
  <div class="clearfix"></div>

  <span data-bind="editable: comment, editableOptions: {enabled: true, placement: 'right', emptytext: '${ _ko('Add a description...') }' }" class="editable editable-click editable-empty">
    ${ _('Add a description...') }
  </span>

  <ul class="nav nav-pills margin-top-30">
    <li><a href="#overview" data-toggle="tab">${_('Overview')}</a></li>
    <li><a href="#columns" data-toggle="tab">${_('Columns')} (<span data-bind="text: columns().length"></span>)</a></li>
    <!-- ko if: tableDetails() && tableDetails().partition_keys.length -->
      <li><a href="#partitions" data-toggle="tab">${_('Partitions')} <span data-bind="text: '(' + partitions.values().length + ')'"></span></a></li>
    <!-- /ko -->
    <li><a href="#sample" data-toggle="tab">${_('Sample')}</a></li>
    <li><a href="#permissions" data-toggle="tab">${_('Permissions')}</a></li>
    <li><a href="#queries" data-toggle="tab">${_('Queries')}</a></li>
    <li><a href="#analysis" data-toggle="tab">${_('Analyse')}</a></li>
    <li><a href="#lineage" data-toggle="tab">${_('Lineage')}</a></li>
    <li><a href="#properties" data-toggle="tab">${ _('Properties') }</a></li>
  </ul>

  <div class="tab-content margin-top-10" style="border: none">
    <div class="tab-pane" id="overview">

      <div class="row-fluid margin-top-10">
        <div class="span6 tile">
          <!-- ko template: 'metastore-table-stats' --><!-- /ko -->
        </div>

        <div class="span2 tile">
          <h4>${ _('Sharing') }</h4>
          <div title="${ _('Tags') }"><i class="fa fa-fw fa-tags muted"></i> ${ _('No tags') }</div>
          <div title="${ _('Users') }"><i class="fa fa-fw fa-users muted"></i> ${ _('No users') }</div>
        </div>

        <div class="span4 tile">
          <h4>${ _('Comments') }</h4>
          <div>
            <i class="fa fa-fw fa-comments-o muted"></i> ${ _('No comments available yet.') }
          </div>
        </div>
      </div>

      <div class="tile">
        <h4>${ _('Columns') } (<span data-bind="text: columns().length"></span>)</h4>
        <!-- ko with: favouriteColumns -->
        <!-- ko template: "metastore-columns-table" --><!-- /ko -->
        <!-- /ko -->

        <a class="pointer" data-bind="visible: columns().length >= 3, click: function() { $('li a[href=\'#columns\']').click(); }">
          ${_('View more...')}
        </a>
      </div>

      <div class="tile" data-bind="visible: true" style="display: none;">
        <!-- ko with: samples -->
        <h4>${ _('Sample') } <i data-bind="visible: loading" class='fa fa-spinner fa-spin' style="display: none;"></i></h4>
        <!-- ko if: loaded -->
        <!-- ko with: preview -->
        <!-- ko template: { if: rows().length, name: 'metastore-samples-table' } --><!-- /ko -->
        <a class="pointer" data-bind="visible: rows().length >= 3, click: function() { $('li a[href=\'#sample\']').click(); }"  style="display: none;">
          ${_('View more...')}
        </a>
        <!-- /ko -->
        <span data-bind="visible: !rows().length && metastoreTable.tableDetails().is_view" style="display: none;">${ _('The view does not contain any data') }</span>
        <span data-bind="visible: !rows().length && !metastoreTable.tableDetails().is_view" style="display: none;">${ _('The table does not contain any data') }</span>
        <!-- /ko -->
        <!-- /ko -->
      </div>

      <div class="tile" data-bind="visible: tableDetails() && tableDetails().partition_keys.length" style="display: none;">
        <!-- ko with: partitions -->
        <h4>${ _('Partitions') } <i data-bind="visible: loading" class='fa fa-spinner fa-spin' style="display: none;"></i></h4>
        <!-- ko if: loaded -->
        <!-- ko with: preview -->
        <!-- ko template: { if: values().length, name: 'metastore-partition-values-table' } --><!-- /ko -->
        <a class="pointer" data-bind="visible: values().length >= 3, click: function() { $('li a[href=\'#partitions\']').click(); }"  style="display: none;">
          ${_('View more...')}
        </a>
        <!-- /ko -->
        <span data-bind="visible: !values().length" style="display: none;">${ _('The partition does not contain any values') }</span>
        <!-- /ko -->
        <!-- /ko -->
      </div>
    </div>

    <div class="tab-pane" id="columns">
      <!-- ko with: columns -->
      <!-- ko template: "metastore-columns-table" --><!-- /ko -->
      <!-- /ko -->
    </div>

    <div class="tab-pane" id="partitions">
      <!-- ko with: partitions -->
      <div class="tile" data-bind="visible: true" style="display: none;">
        <h4>${ _('Columns') }</h4>
        <!-- ko template: 'metastore-partition-columns-table' --><!-- /ko -->
      </div>
      <div class="tile" data-bind="visible: true" style="display: none;">
        <h4>${ _('Partitions') } <i data-bind="visible: loading" class='fa fa-spinner fa-spin' style="display: none;"></i></h4>
        <!-- ko if: loaded -->
        <!-- ko template: { if: values().length, name: 'metastore-partition-values-table' } --><!-- /ko -->
        <span data-bind="visible: !values().length" style="display: none;">${ _('The partition does not contain any values') }</span>
        <!-- /ko -->
      </div>
      <!-- /ko -->
      <a data-bind="attr: { 'href': '/metastore/table/' + database.name + '/' + name + '/partitions' }">${ _('View all') }</a>
    </div>

    <div class="tab-pane" id="sample">
      <!-- ko with: samples -->
      <!-- ko if: loaded -->
      <!-- ko template: { if: rows().length, name: 'metastore-samples-table' } --><!-- /ko -->
      <span data-bind="visible: !rows().length && metastoreTable.tableDetails().is_view" style="display: none;">${ _('The view does not contain any data') }</span>
      <span data-bind="visible: !rows().length && !metastoreTable.tableDetails().is_view" style="display: none;">${ _('The table does not contain any data') }</span>
      <!-- /ko -->
      <!-- /ko -->
    </div>

    <div class="tab-pane" id="permissions">
      ${ _('Not available') }
    </div>

    <div class="tab-pane" id="queries">
      <i class="fa fa-spinner fa-spin" data-bind="visible: $root.loadingQueries"></i>
      <table data-bind="visible: !$root.loadingQueries()" class="table table-condensed">
        <thead>
        <tr>
          <th width="20%">${ _('Name') }</th>
          <th>${ _('Query') }</th>
          <th width="20%">${ _('Owner') }</th>
        </tr>
        </thead>
        <tbody data-bind="foreach: $root.queries">
        <tr class="pointer" data-bind="click: function(){ location.href=doc.absoluteUrl; }">
          <td data-bind="text: doc.name"></td>
          <td><code data-bind="text: data.snippets[0].statement_raw"></code></td>
          <td><code data-bind="text: doc.owner"></code></td>
        </tr>
        </tbody>
      </table>
    </div>

    <div class="tab-pane" id="analysis">
      ${ _('Not available') }
    </div>

    <div class="tab-pane" id="lineage">
      ${ _('Not available') }
    </div>

    <div class="tab-pane" id="properties">
      <table class="table table-striped table-condensed">
        <thead>
        <tr>
          <th>${ _('Name') }</th>
          <th>${ _('Value') }</th>
          <th>${ _('Comment') }</th>
        </tr>
        </thead>
        <tbody>
##           % for prop in table.properties:
##             <tr>
##               <td>${ smart_unicode(prop['col_name']) }</td>
##               <td>${ smart_unicode(prop['data_type']) if prop['data_type'] else '' }</td>
##               <td>${ smart_unicode(prop['comment']) if prop['comment'] else '' }&nbsp;</td>
##             </tr>
##           % endfor
        </tbody>
      </table>
    </div>
  </div>
</script>

<div class="main-content">
  <div class="vertical-full container-fluid" data-bind="style: { 'padding-left' : $root.isLeftPanelVisible() ? '0' : '20px' }">
    <div class="vertical-full">
      <div class="vertical-full row-fluid panel-container">

        <div class="assist-container left-panel" data-bind="visible: $root.isLeftPanelVisible() && $root.assistAvailable()">
          <a title="${_('Toggle Assist')}" class="pointer hide-assist" data-bind="click: function() { $root.isLeftPanelVisible(false) }">
            <i class="fa fa-chevron-left"></i>
          </a>
          <div class="assist" data-bind="component: {
              name: 'assist-panel',
              params: {
                sourceTypes: [{
                  name: 'hive',
                  type: 'hive'
                }],
                user: '${user.username}',
                navigationSettings: {
                  openItem: true,
                  showPreview: true,
                  showStats: false
                }
              }
            }"></div>
        </div>
        <div class="resizer" data-bind="visible: $root.isLeftPanelVisible() && $root.assistAvailable(), splitDraggable : { appName: 'notebook', leftPanelVisible: $root.isLeftPanelVisible }"><div class="resize-bar">&nbsp;</div></div>
        <div class="right-panel">
          <div class="metastore-main">
            <h3>
              <!-- ko template: { if: database() !== null && database().table() !== null, name: 'metastore-describe-table-actions' }--><!-- /ko -->
              <!-- ko template: { if: database() !== null && database().table() === null, name: 'metastore-tables-actions' }--><!-- /ko -->
              <!-- ko template: { if: database() === null, name: 'metastore-databases-actions' }--><!-- /ko -->
              <!-- ko template: 'metastore-breadcrumbs' --><!-- /ko -->
            </h3>
            <i data-bind="visible: loading" class="fa fa-spinner fa-spin fa-2x margin-left-10" style="color: #999; display: none;"></i>
            <!-- ko template: { if: !loading() && database() === null, name: 'metastore-databases' } --><!-- /ko -->
            <!-- ko with: database -->
            <i data-bind="visible: loading" class="fa fa-spinner fa-spin fa-2x margin-left-10" style="color: #999; display: none;"></i>
            <!-- ko template: { if: !loading() && table() === null, name: 'metastore-tables' } --><!-- /ko -->
            <!-- ko with: table -->
              <!-- ko template: 'metastore-describe-table' --><!-- /ko -->
            <!-- /ko -->
            <!-- /ko -->
          </div>
        </div>
    </div>
  </div>
</div>



<div id="dropSingleTable" class="modal hide fade">
  <form method="POST" data-bind="attr: { 'action': '/metastore/tables/drop/' + (database() ? database().name : '') }">
    ${ csrf_token(request) | n,unicode }
    <div class="modal-header">
      <a href="#" class="close" data-dismiss="modal">&times;</a>
      <h3>${_('Drop Table')}</h3>
    </div>
    <div class="modal-body">
      <div>${_('Do you really want to drop the table')} <span style="font-weight: bold;" data-bind="text: database() && database().table() ? database().table().name : ''"></span>?</div>
    </div>
    <div class="modal-footer">
      <input type="button" class="btn" data-dismiss="modal" value="${_('Cancel')}"/>
      <input type="submit" data-bind="click: function () { huePubSub.publish('assist.refresh'); return true; }" class="btn btn-danger" value="${_('Yes, drop this table')}"/>
    </div>
    <div class="hide">
      <!-- ko with: database -->
      <!-- ko with: table -->
      <input type="hidden" name="table_selection" data-bind="value: name" />
      <!-- /ko -->
      <!-- /ko -->
    </div>
  </form>
</div>

<div id="import-data-modal" class="modal hide fade"></div>
</div>

<script src="${ static('beeswax/js/stats.utils.js') }"></script>

<script type="text/javascript" charset="utf-8">

  require([
    "knockout",
    "ko.charts",
    "desktop/js/assist/assistHelper",
    "assistPanel",
    "tableStats",
    "knockout-mapping",
    "knockout-sortable",
    "ko.editable",
    "ko.hue-bindings"
  ], function (ko, charts, AssistHelper) {

    ko.options.deferUpdates = true;

    /**
     * @param {Object} options
     * @param {string} options.name
     * @param {AssistHelper} options.assistHelper
     * @param {string} [options.tableName]
     * @param {string} [options.tableComment]
     * @constructor
     */
    function MetastoreDatabase(options) {
      var self = this;
      self.assistHelper = options.assistHelper;
      self.name = options.name;

      self.loaded = ko.observable(false);
      self.loading = ko.observable(false);
      self.tables = ko.observableArray();
      self.stats = ko.observable();

      self.tableQuery = ko.observable('').extend({rateLimit: 150});

      self.filteredTables = ko.computed(function () {
        if (self.tableQuery() === '') {
          return self.tables();
        }
        return $.grep(self.tables(), function (table) {
          return table.name.toLowerCase().indexOf(self.tableQuery()) > -1
              || (table.comment() && table.comment().toLowerCase().indexOf(self.tableQuery()) > -1);
        });
      });

      self.selectedTables = ko.observableArray();

      self.table = ko.observable(null);
    }

    MetastoreDatabase.prototype.load = function (callback) {
      var self = this;
      if (self.loading()) {
        return;
      }

      self.loading(true);
      self.assistHelper.fetchTables({
        sourceType: 'hive',
        databaseName: self.name,
        successCallback: function (data) {
          self.tables($.map(data.tables_meta, function (tableMeta) {
            return new MetastoreTable({
              database: self,
              name: tableMeta.name,
              type: tableMeta.type,
              comment: tableMeta.comment,
              assistHelper: self.assistHelper
            })
          }));
          self.loaded(true);
          self.loading(false);
          if (callback) {
            callback();
          }
        },
        errorCallback: function (response) {
          console.error('MetastoreDatabase.load error');
          console.error(response);
          self.loading(false);
          if (callback) {
            callback();
          }
        }
      });

      $.getJSON('/metastore/databases/' + self.name + '/metadata', function (data) {
        if (data && data.status == 0) {
          self.stats(data.data);
        }
      });

      $.totalStorage('hue.metastore.lastdb', self.name);
    };

    MetastoreDatabase.prototype.setTableByName = function (tableName) {
      var self = this;
      var foundTables = $.grep(self.tables(), function (metastoreTable) {
        return metastoreTable.name === tableName;
      });

      if (foundTables.length === 1) {
        self.setTable(foundTables[0]);
      }
    };

    MetastoreDatabase.prototype.setTable = function (metastoreTable, callback) {
      var self = this;
      self.table(metastoreTable);
      if (!metastoreTable.loaded()) {
        metastoreTable.load();
      }
      if (callback) {
        callback();
      }
      window.setTimeout(function () {
        $('a[href="#overview"]').click();
      }, 200);
    };

    /**
     * @param {Object} options
     * @param {AssistHelper} options.assistHelper
     * @param {MetastoreTable} options.metastoreTable
     */
    function MetastoreTablePartitions(options) {
      var self = this;
      self.detailedKeys = ko.observableArray();
      self.keys = ko.observableArray();
      self.values = ko.observableArray();
      self.metastoreTable = options.metastoreTable;
      self.assistHelper = options.assistHelper;

      self.loaded = ko.observable(false);
      self.loading = ko.observable(true);

      self.preview = {
        keys: ko.observableArray(),
        values: ko.observableArray()
      }
    }

    MetastoreTablePartitions.prototype.load = function () {
      var self = this;
      if (self.loaded()) {
        return;
      }
      self.assistHelper.fetchPartitions({
        databaseName: self.metastoreTable.database.name,
        tableName: self.metastoreTable.name,
        successCallback: function (data) {
          self.keys(data.partition_keys_json);
          self.values(data.partition_values_json);
          self.preview.values(self.values().slice(0, 3));
          self.preview.keys(self.keys());
          self.loading(false);
          self.loaded(true);
        },
        errorCallback: function (data) {
          console.error('assistHelper.fetchPartitions error');
          console.error(data);
          self.loading(false);
          self.loaded(true);
        }
      })
    };

    /**
     * @param {Object} options
     * @param {AssistHelper} options.assistHelper
     * @param {MetastoreTable} options.metastoreTable
     */
    function MetastoreTableSamples(options) {
      var self = this;
      self.rows = ko.observableArray();
      self.headers = ko.observableArray();
      self.metastoreTable = options.metastoreTable;
      self.assistHelper = options.assistHelper;

      self.loaded = ko.observable(false);
      self.loading = ko.observable(true);

      self.preview = {
        headers: ko.observableArray(),
        rows: ko.observableArray()
      }
    }

    MetastoreTableSamples.prototype.load = function () {
      var self = this;
      if (self.loaded()) {
        return;
      }
      self.assistHelper.fetchTableSample({
        sourceType: "hive",
        databaseName: self.metastoreTable.database.name,
        tableName: self.metastoreTable.name,
        dataType: "json",
        successCallback: function (data) {
          self.rows(data.rows);
          self.headers(data.headers);
          self.preview.rows(self.rows().slice(0, 3));
          self.preview.headers(self.headers());
          self.loading(false);
          self.loaded(true);
        },
        errorCallback: function (data) {
          $.jHueNotify.error('${_('An error occurred fetching the table sample. Please try again.')}');
          console.error('assistHelper.fetchTableSample error');
          console.error(data);
          self.loading(false);
          self.loaded(true);
        }
      });
    };


    /**
     * @param {Object} options
     * @param {MetastoreDatabase} options.database
     * @param {string} options.name
     * @param {string} options.type
     * @param {string} options.comment
     * @param {AssistHelper} options.assistHelper
     * @constructor
     */
    function MetastoreTable(options) {
      var self = this;
      self.database = options.database;
      self.assistHelper = options.assistHelper;
      self.name = options.name;
      self.type = options.type;

      self.loaded = ko.observable(false);
      self.loading = ko.observable(false);

      self.columns = ko.observableArray();
      self.favouriteColumns = ko.observableArray();
      self.samples = new MetastoreTableSamples({
        assistHelper: self.assistHelper,
        metastoreTable: self
      });
      self.partitions = new MetastoreTablePartitions({
        assistHelper: self.assistHelper,
        metastoreTable: self
      });
      self.tableDetails = ko.observable();
      self.tableStats = ko.observable();
      self.refreshingTableStats = ko.observable(false);

      //TODO: Fetch table comment async and don't set it from python
      self.comment = ko.observable(options.comment);

      self.comment.subscribe(function (newValue) {
        $.post('/metastore/table/' + self.database.name + '/' + self.name + '/alter', {
          comment: newValue ? newValue : ""
        }, function () {
          self.assistHelper.clearCache({
            sourceType: 'hive',
            databaseName: self.database.name
          })
        });
      });

      self.refreshTableStats = function () {
        if (self.refreshingTableStats()) {
          return;
        }
        self.refreshingTableStats(true);
        self.assistHelper.refreshTableStats({
          tableName: self.name,
          databaseName: self.database.name,
          sourceType: "hive",
          successCallback: function (data) {
            self.fetchDetails();
          },
          errorCallback: function (data) {
            self.refreshingTableStats(false);
            $.jHueNotify.error('${_('An error occurred refreshing the table stats. Please try again.')}');
            console.error('assistHelper.refreshTableStats error');
            console.error(data);
          }
        })
      };

      self.fetchFields = function () {
        var self = this;
        self.assistHelper.fetchFields({
          sourceType: "hive",
          databaseName: self.database.name,
          tableName: self.name,
          fields: [],
          successCallback: function (data) {
            self.columns($.map(data.extended_columns, function (column) {
              return new MetastoreColumn({
                extendedColumn: column,
                table: self
              })
            }));
            self.favouriteColumns(self.columns().slice(0, 3));
          },
          errorCallback: function (data) {
            $.jHueNotify.error('${_('An error occurred fetching the table fields. Please try again.')}');
            console.error('assistHelper.fetchFields error');
            console.error(data);
          }
        })
      };

      self.fetchDetails = function () {
        var self = this;
        self.assistHelper.fetchTableDetails({
          sourceType: "hive",
          databaseName: self.database.name,
          tableName: self.name,
          successCallback: function (data) {
            self.tableDetails(data);
            self.tableStats(data.details.stats);
            self.refreshingTableStats(false);
            self.samples.load();
            self.loaded(true);
            self.loading(false);
            if (data.partition_keys.length) {
              self.partitions.detailedKeys(data.partition_keys);
              self.partitions.load();
            } else {
              self.partitions.loading(false);
              self.partitions.loaded(true);
            }
          },
          errorCallback: function (data) {
            self.refreshingTableStats(false);
            $.jHueNotify.error('${_('An error occurred fetching the table details. Please try again.')}');
            console.error('assistHelper.fetchTableDetails error');
            console.error(data);
            self.loading(false);
          }
        })
      }
    }

    MetastoreTable.prototype.showImportData = function () {
      var self = this;
      $.get('/metastore/table/' + self.database.name + '/' + self.name + '/load', function (response) {
        $("#import-data-modal").html(response['data']);
        $("#import-data-modal").modal("show");
      });
    };

    MetastoreTable.prototype.load = function () {
      var self = this;
      if (self.loading()) {
        return;
      }
      self.loading(true);
      self.fetchFields();
      self.fetchDetails();
    };

    /**
     * @param {Object} options
     * @param {MetastoreTable} options.table
     * @param {object} options.extendedColumn
     * @constructor
     */
    function MetastoreColumn(options) {
      var self = this;
      self.table = options.table;
      ko.mapping.fromJS(options.extendedColumn, {}, self);

      self.favourite = ko.observable(false);

      self.comment.subscribe(function (newValue) {
        $.post('/metastore/table/' + self.table.database.name + '/' + self.table.name + '/alter_column', {
          column: self.name(),
          comment: newValue
        }, function () {
          self.table.assistHelper.clearCache({
            sourceType: 'hive',
            databaseName: self.table.database.name,
            tableName: self.table.name
          })
        });
      })
    }

    /**
     * @param {Object} options
     * @param {Object} options.i18n
     * @param {string} options.i18n.errorLoadingDatabases
     * @param {string} options.i18n.errorLoadingTablePreview
     * @param {string} options.user
     * @constructor
     */
    function MetastoreViewModel(options) {
      var self = this;
      self.assistAvailable = ko.observable(true);
      self.isLeftPanelVisible = ko.observable(self.assistAvailable() && $.totalStorage('spark_left_panel_visible') != null && $.totalStorage('spark_left_panel_visible'));

      self.assistHelper = new AssistHelper(options);

      self.reloading = ko.observable(false);
      self.loading = ko.observable(false);
      self.databases = ko.observableArray();

      self.selectedDatabases = ko.observableArray();

      self.databaseQuery = ko.observable('').extend({rateLimit: 150});

      self.filteredDatabases = ko.computed(function () {
        if (self.databaseQuery() === '') {
          return self.databases();
        }
        return $.grep(self.databases(), function (database) {
          return database.name.toLowerCase().indexOf(self.databaseQuery()) > -1;
        });
      });

      self.database = ko.observable(null);

      var loadDatabases = function (successCallback) {
        if (self.loading()) {
          return;
        }
        self.loading(true);
        self.assistHelper.loadDatabases({
          sourceType: 'hive',
          callback: function (databaseNames) {
            self.databases($.map(databaseNames, function (name) {
              return new MetastoreDatabase({
                name: name,
                assistHelper: self.assistHelper
              })
            }));
            self.loading(false);
            if (successCallback) {
              successCallback();
            }
          }
        });
      };

      loadDatabases();

      var setDatabaseByName = function (databaseName, callback) {
        if (databaseName === '') {
          databaseName = $.totalStorage('hue.metastore.lastdb') || 'default';
        }
        if (self.database() && self.database().name == databaseName) {
          if (callback) {
            callback();
          }
          return;
        }
        var foundDatabases = $.grep(self.databases(), function (database) {
          return database.name === databaseName;
        });
        if (foundDatabases.length === 1) {
          self.setDatabase(foundDatabases[0], callback);
        }
      };

      var loadTableDef = function (tableDef, callback) {
        setDatabaseByName(tableDef.database);
        if (self.database()) {
          if (self.database().table() && self.database().table().name == tableDef.name) {
            return;
          }

          var setTableAfterLoad = function () {
            var foundTables = $.grep(self.database().tables(), function (table) {
              return table.name === tableDef.name;
            });
            if (foundTables.length === 1) {
              self.database().setTable(foundTables[0], callback);
            }
          };

          if (!self.database().loaded()) {
            var doOnce = self.database().loaded.subscribe(function () {
              setTableAfterLoad();
              doOnce.dispose();
            })
          } else {
            setTableAfterLoad();
          }
        }
      };

      huePubSub.subscribe('assist.refresh', function () {
        self.reloading(true);
        self.assistHelper.clearCache({
          sourceType: 'hive',
          clearAll: true
        });
        var currentDatabase = null;
        var currentTable = null;
        if (self.database()) {
          currentDatabase = self.database().name;
          if (self.database().table()) {
            currentTable = self.database().table().name;
            self.database().table(null);
          }
          self.database(null);
        }
        loadDatabases(function () {
          if (currentDatabase) {
            setDatabaseByName(currentDatabase, function () {
              if (self.database() && currentTable) {
                self.database().setTableByName(currentTable);
              }
              self.reloading(false);
            });
          } else {
            self.reloading(false);
          }
        });
      });

      huePubSub.subscribe("assist.table.selected", function (tableDef) {
        loadTableDef(tableDef, function () {
          huePubSub.publish('metastore.url.change')
        });
      });

      huePubSub.subscribe("assist.database.selected", function (databaseDef) {
        if (self.database()) {
          self.database().table(null);
        }
        setDatabaseByName(databaseDef.name, function () {
          huePubSub.publish('metastore.url.change')
        });
      });

      self.isLeftPanelVisible.subscribe(function (newValue) {
        $.totalStorage('spark_left_panel_visible', newValue);
      });

      huePubSub.subscribe('metastore.url.change', function () {
        if (self.database() && self.database().table()) {
          hueUtils.changeURL('/metastore/table/' + self.database().name + '/' + self.database().table().name);
        }
        else if (self.database()) {
          hueUtils.changeURL('/metastore/tables/' + self.database().name);
        }
        else {
          hueUtils.changeURL('/metastore/databases');
        }
      });

      // TODO: Move queries into MetastoreTable
      self.loadingQueries = ko.observable(false);
      self.queries = ko.observableArray([]);


      function loadURL() {
        var path = window.location.pathname.split('/');
        switch (path[2]) {
          case 'databases':
            if (self.database()) {
              self.database().table(null);
              self.database(null);
            }
            break;
          case 'tables':
            if (self.database()) {
              self.database().table(null);
            }
            setDatabaseByName(path[3]);
            break;
          case 'table':
            loadTableDef({
              name: path[4],
              database: path[3]
            });
            break;
        }
      }

      loadURL();

      window.onpopstate = loadURL;

      self.databasesBreadcrumb = function () {
        if (self.database()) {
          self.database().table(null);
        }
        self.database(null);
        huePubSub.publish('metastore.url.change');
      }

      self.tablesBreadcrumb = function () {
        self.database().table(null);
        huePubSub.publish('metastore.url.change')
      }
    }

    MetastoreViewModel.prototype.setDatabase = function (metastoreDatabase, callback) {
      var self = this;
      self.database(metastoreDatabase);

      if (!metastoreDatabase.loaded()) {
        metastoreDatabase.load(callback);
      } else if (callback) {
        callback();
      }
    };

    $(document).ready(function () {
      var options = {
        user: '${ user.username }',
        i18n: {
          errorLoadingDatabases: "${ _('There was a problem loading the databases') }",
          errorLoadingTablePreview: "${ _('There was a problem loading the table preview.') }"
        }
      };

      var viewModel = new MetastoreViewModel(options);

      ko.applyBindings(viewModel);

      // TODO: Use ko for this and the put the queries in the MetastoreTable
      $('a[data-toggle="tab"]').on('shown', function (e) {
        if ($(e.target).attr("href") == "#queries") {
          viewModel.loadingQueries(true);
          $.getJSON('/metastore/table/' + viewModel.database().name + '/' + viewModel.database().table().name + '/queries', function (data) {
            viewModel.queries(data.queries);
            viewModel.loadingQueries(false);
          });
        }
      });

    });
  });

  $(document).ready(function () {
    function selectColumn(col) {
      var _t = $("#sampleTable");
      var _col = _t.find("th").filter(function () {
        return $.trim($(this).text()).indexOf(col) > -1;
      });
      _t.find(".columnSelected").removeClass("columnSelected");
      _t.find("tr td:nth-child(" + (_col.index() + 1) + ")").addClass("columnSelected");
      $("a[href='#sample']").click();

    }

    $(".column-selector").on("click", function () {
      selectColumn($.trim($(this).text().split("(")[0]));
    });

    if (window.location.hash != "") {
      if (window.location.hash.indexOf("col=") > -1) {
        window.setTimeout(function () {
          selectColumn(window.location.hash.split("=")[1]);
        }, 200)
      }
    }

    $('a[data-toggle="tab"]').on('shown', function (e) {
      var sortables = [];
      $(".sampleTable").not('.initialized').each(function () {
        var _id = $(this).attr("id");
        if (sortables[_id] === undefined) {
          sortables[_id] = [];
        }
        $('#' + _id + ' thead th').each(function () {
          if ($(this).hasClass('no-sort')) {
            sortables[_id].push({
              "bSortable": false
            });
          } else {
            sortables[_id].push(null);
          }
        });
      });

      for (var id in sortables) {
        $("#" + id).addClass("initialized");
        ##         % if len(table.cols) < 1000:
        ##         $("#" + id).dataTable({
        ##           "aoColumns": sortables[id],
        ##           "bPaginate": false,
        ##           "bLengthChange": false,
        ##           "bInfo": false,
        ##           "bFilter": false,
        ##           "bAutoWidth": false,
        ##           "fnInitComplete": function () {
        ##             $(this).parent().jHueTableScroller();
        ##             if (! $(this).hasClass("skip-extender")) {
        ##               $(this).jHueTableExtender({
        ##                 hintElement: "#jumpToColumnAlert",
        ##                 fixedHeader: true
        ##               });
        ##             }
        ##           },
        ##           "oLanguage": {
        ##             "sEmptyTable": "${_('No data available')}",
        ##             "sZeroRecords": "${_('No matching records')}"
        ##           }
        ##         });
        ##         % endif
              }
    });

    $('a[data-toggle="tab"]:eq(0)').click();
  });
</script>

${ commonfooter(request, messages) | n,unicode }
