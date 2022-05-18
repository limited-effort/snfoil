# Update Context

Update sets up an object using the build functionality, and then attempts to save it to the data source.

Update does the following:

- Find a model
- Assigns attributes
- Saves object

##### Example

```ruby
class PeopleContext
  include SnFoil::CRUD::UpdateContext

  searcher PeopleSearcher
  model Person
end
```

### Required Class Definitions

- Searcher
- Model

### Primary Action
Saves the model

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
      <td>setup_change</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>setup_update</td>
      <td></td>
      <td>
        Finds the model, Assigns attributes
      </td>
    </tr>
    <tr>
      <td>before_change</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>before_update</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change_success</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>after_update_success</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change_failure</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>after_update_failure</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>after_update</td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>

### ORM Adapter Requirements

The following methods must be defined on the ORM adapter to use the update context

- `attributes=`
- `save`
