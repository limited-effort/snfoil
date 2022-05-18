# Show Context

Show sets up an object using the build functionality, and then attempts to save it to the data source.

Show does the following:

- Finds the model

##### Example

```ruby
class PeopleContext
  include SnFoil::CRUD::ShowContext

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
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>setup_show</td>
      <td>Shared by all CRUD actions</td>
      <td></td>
    </tr>
    <tr>
      <td>before_show</td>
      <td></td>
      <td>Finds the model</td>
    </tr>
    <tr>
      <td>after_show_success</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_show_failure</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_show</td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>
