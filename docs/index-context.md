# Index Context

Index sets up an object using the build functionality, and then attempts to save it to the data source.

Index does the following:

- Queries for models

##### Example

```ruby
class PeopleContext
  include SnFoil::CRUD::IndexContext

  searcher PeopleSearcher
  policy PersonPolicy
  model Person
end
```

### Required Class Definitions

- Searcher
- Policy
- Model

### Primary Action
Does nothing
### Intervals (in order)

<table>
  <thead>
    <th>name</th>
    <th>description</th>
    <th>pre-defined functions</th>
  </thead>

  <tbody>
    <tr>
      <td>setup</td>
      <td>Shared by all CRUD actions</td>
      <td></td>
    </tr>
    <tr>
      <td>setup_index</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>before_index</td>
      <td></td>
      <td>Queries for models</td>
    </tr>
    <tr>
      <td>after_index_success</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_index_failure</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_index</td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>
